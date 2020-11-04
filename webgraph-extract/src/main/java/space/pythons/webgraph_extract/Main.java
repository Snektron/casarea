package space.pythons.webgraph_extract;

import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.util.function.BiConsumer;

import it.unimi.dsi.webgraph.BVGraph;
import it.unimi.dsi.webgraph.NodeIterator;

public class Main {
    static void writeIntLittleEndian(OutputStream out, int value) throws IOException {
        out.write(value & 0xFF);
        out.write((value >> 8) & 0xFF);
        out.write((value >> 16) & 0xFF);
        out.write((value >> 24) & 0xFF);
    }

    static void writeEdges(BVGraph graph, OutputStream out) throws IOException {
        var it = graph.nodeIterator();
        while (it.hasNext()) {
            int src = it.nextInt();
            int degree = it.outdegree();
            int[] succ = it.successorArray();

            for (int i = 0; i < degree; ++i) {
                int dst = succ[i];

                writeIntLittleEndian(out, src);
                writeIntLittleEndian(out, dst);
            }
        }
    }

    public static void main(String[] args) throws Throwable {
        if (args.length != 2) {
            System.err.println("Missing argument: Required arguments <graph basename> <edges output>");
            return;
        }

        var graph = BVGraph.load(args[0], 0);
        System.out.printf("Writing %.2f GB of edges\n", (double) graph.numArcs() * 4 * 2 / 1000000000);

        try (var bos = new BufferedOutputStream(new FileOutputStream(args[1]))) {
            writeEdges(graph, bos);
        }
    }
}
