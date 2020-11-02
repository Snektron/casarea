#include <iostream>
#include <vector>
#include <chrono>
#include <ctime>
#include <cstdlib>

const size_t ITERATIONS = 20;
const size_t NUM_NODES = 100'000;
const size_t NUM_EDGES = 100'000'000;

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

void pagerank(const Graph& graph, float alpha) {
	std::vector<float> a;
	a.resize(graph.nodes(), 0.0f);
	std::vector<float> b;
	b.resize(graph.nodes(), 0.0f);
	std::vector<node_type> d;
	d.resize(graph.nodes(), 0);
	
	graph.map_edges([&](node_type x, node_type y) {
		d[x] += 1;
	});
	
	for(size_t iter = 0; iter < ITERATIONS; ++iter) {
		for(size_t i = 0; i < graph.nodes(); ++i) {
			b[i] = alpha * a[i] / d[i];
			a[i] = 1.0f - alpha;
		}
		
		graph.map_edges([&](node_type x, node_type y) {
			a[y] += b[x];
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
		pagerank(g, 0.85);
	});
	return 0;
}