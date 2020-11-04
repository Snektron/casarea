#include <iostream>
#include <vector>
#include <utility>
#include <fstream>
#include <algorithm>
#include <cstdlib>
#include <cstdint>
#include <cstring>

using NodeId = uint32_t;

class Graph {
    private:
        NodeId max_node_id;
        std::vector<NodeId> sources;
        std::vector<NodeId> dests;

    public:
        inline size_t nodes() const {
            return this->max_node_id + 1;
        }

        inline size_t edges() const {
            return this->sources.size();
        }

        template <typename T>
        void map_edges(T callback) const {
            for(size_t i = 0; i < sources.size(); ++i) {
                callback(sources[i], dests[i]);
            }
        }

        void add_edge(NodeId a, NodeId b) {
            this->sources.push_back(a);
            this->dests.push_back(b);
            this->max_node_id = std::max({a, b, this->max_node_id});
        }
};

Graph read_graph(const char* path) {
    auto g = Graph();

    auto f = std::ifstream(path);
    if (!f) {
        std::cerr << "Failed to open " << path << std::endl;
        exit(EXIT_FAILURE);
    }

    uint8_t x[8];
    while (f.read(reinterpret_cast<char*>(x), sizeof(x))) {
        NodeId src = x[0] | (x[1] << 8) | (x[2] << 16) | (x[3] << 24);
        NodeId dst = x[4] | (x[5] << 8) | (x[6] << 16) | (x[7] << 24);
        g.add_edge(src, dst);
    }

    return g;
}

void pagerank(const Graph& graph, size_t iterations, float alpha) {
    std::vector<float> a;
    a.resize(graph.nodes(), 0.0f);
    std::vector<float> b;
    b.resize(graph.nodes(), 0.0f);
    std::vector<NodeId> d;
    d.resize(graph.nodes(), 0);

    graph.map_edges([&](NodeId x, NodeId y) {
        d[x] += 1;
    });

    for(size_t iter = 0; iter < iterations; ++iter) {
        for(size_t i = 0; i < graph.nodes(); ++i) {
            b[i] = alpha * a[i] / d[i];
            a[i] = 1.0f - alpha;
        }

        graph.map_edges([&](NodeId x, NodeId y) {
            a[y] += b[x];
        });
    }
}

void label_propagation(const Graph& graph) {
    std::vector<NodeId> label;
    label.resize(graph.nodes());
    for(size_t i = 0; i < graph.nodes(); ++i) {
        label[i] = i;
    }

    bool done = false;
    while(!done) {
        done = true;

        graph.map_edges([&](NodeId x, NodeId y) {
            if(label[x] != label[y]) {
                done = false;
                label[x] = std::min(label[x], label[y]);
                label[y] = std::min(label[x], label[y]);
            }
        });
    }
}

int main(int argc, const char* argv[]) {
    if (argc <= 2) {
        std::cout << "Usage: " << argv[0] << " <pagerank | label> <graph.edges>" << std::endl;
        return EXIT_FAILURE;
    }

    auto g = read_graph(argv[2]);

    if (std::strcmp(argv[1], "pagerank") == 0) {
        pagerank(g, 20, 0.015);
    } else if (std::strcmp(argv[1], "label") == 0) {
        label_propagation(g);
    } else{
        std::cerr << "Invalid argument '" << argv[1] << "'" << std::endl;
    }

    return EXIT_SUCCESS;
}
