#include <iostream>
#include <cstdint>
#include <vector>
#include <chrono>

const size_t NUM_NODES = 1'000'000;
const size_t NUM_EDGES = 10'000'000;

using node_type = uint32_t;

class Graph {
    private:
        std::vector<node_type> sources;
        std::vector<node_type> dests;
    public:
        inline size_t nodes() const {
            return NUM_NODES;
        }

        template <typename T>
        void map_edges(T callback) const {
            for(size_t i = 0; i < sources.size(); ++i) {
                callback(sources[i], dests[i]);
            }
        }

        void addEdge(node_type a, node_type b) {
            this->sources.push_back(a);
            this->dests.push_back(b);
        }
};

void label_propagation(const Graph& graph) {
    std::vector<node_type> label;
    label.resize(graph.nodes());
    for(size_t i = 0; i < graph.nodes(); ++i) {
        label[i] = i;
    }

    bool done = false;
    while(!done) {
        done = true;

        graph.map_edges([&](node_type x, node_type y) {
            if(label[x] != label[y]) {
                done = false;
                label[x] = std::min(label[x], label[y]);
                label[y] = std::min(label[x], label[y]);
            }
        });
    }
}

template <typename T>
void measure_time(const std::string& str, T callback) {
    auto start = std::chrono::steady_clock::now();
    callback();
    auto end = std::chrono::steady_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);

    std::cout << str << ": " << duration.count() << "ms" << std::endl;
}

int main() {
    Graph g;
    std::srand(std::time(NULL));

    std::cout << "Running with " << NUM_EDGES << " edges and " << NUM_NODES << " nodes" << std::endl;

    for(size_t i = 0; i < NUM_EDGES; ++i) {
        g.addEdge(std::rand() % NUM_NODES, std::rand() % NUM_NODES);
    }

    measure_time("Pagerank", [&] {
        label_propagation(g);
    });
    return 0;
}