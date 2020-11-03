package space.pythons.webgraph_extract;

import it.unimi.dsi.webgraph.BVGraph;
import it.unimi.dsi.webgraph.NodeIterator;

import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
import java.io.OutputStream;

public class Main {
    private static void writeIntLittleEndian(OutputStream out, int value) throws Throwable {
        out.write(value & 0xFF);
        out.write((value >> 8) & 0xFF);
        out.write((value >> 16) & 0xFF);
        out.write((value >> 24) & 0xFF);
    }

    private static void writeNodeEdges(BVGraph graph, NodeIterator it, OutputStream out) throws Throwable {
        int src = it.nextInt();
        int degree = it.outdegree();
        int[] succ = it.successorArray();
        for (int i = 0; i < degree; ++i) {
            int dst = succ[i];
            writeIntLittleEndian(out, src);
            writeIntLittleEndian(out, dst);
        }
    }

    public static void main(String[] args) throws Throwable {
        if (args.length != 2) {
            System.err.println("Missing argument: <graph basename> <edges output>");
            return;
        }

        var graph = BVGraph.load(args[0], 0);
        System.out.printf("Writing %.2f GB of edges\n", graph.numArcs() * 4 * 2 / 1e9);
        try (var fos = new FileOutputStream(args[1])) {
            var bos = new BufferedOutputStream(fos);
            int total_nodes = graph.numNodes();

            var it = graph.nodeIterator();
            while (it.hasNext()) {
                writeNodeEdges(graph, it, bos);
            }
        }
    }
}
