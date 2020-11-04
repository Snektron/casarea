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

    static void writeEdges(BVGraph graph, EdgeWriter writer) throws IOException {
        var it = graph.nodeIterator();
        while (it.hasNext()) {
            int src = it.nextInt();
            int degree = it.outdegree();
            int[] succ = it.successorArray();

            for (int i = 0; i < degree; ++i) {
                int dst = succ[i];
                writer.write(src, dst);
            }
        }
    }

    public static void main(String[] args) throws Throwable {
        if (args.length != 3) {
            System.err.println("Missing argument: Required arguments <graph basename> <edges basename> <edges per chunk>");
            return;
        }

        int edges_per_chunk = Integer.parseInt(args[2], 10);
        var graph = BVGraph.load(args[0], 0);
        int total_files = (int) ((graph.numArcs() + edges_per_chunk - 1) / edges_per_chunk);
        System.out.printf("Writing %d edges to %d files\n", graph.numArcs(), total_files);

        try (var edge_writer = new EdgeWriter(args[1], edges_per_chunk, total_files)) {
            writeEdges(graph, edge_writer);
        }
    }

    static class EdgeWriter implements AutoCloseable {
        String basename;
        BufferedOutputStream bos;
        int edges_per_file;
        int file_num;
        int edges_written;
        int padding;

        EdgeWriter(String basename, int edges_per_file, int total_files) {
            this.basename = basename;
            this.bos = null;
            this.edges_per_file = edges_per_file;
            this.file_num = 0;
            this.edges_written = 0;
            this.padding = String.valueOf(total_files).length();
        }

        void write(int src, int dst) throws IOException {
            if (this.edges_written % this.edges_per_file == 0) {
                if (this.bos != null) {
                    this.bos.close();
                }

                var filename = String.format("%s-%0" + this.padding + "d.edges", this.basename, this.file_num);
                var fos = new FileOutputStream(filename);
                this.bos = new BufferedOutputStream(fos);

                ++this.file_num;
            }

            writeIntLittleEndian(this.bos, src);
            writeIntLittleEndian(this.bos, dst);
            ++this.edges_written;
        }

        @Override
        public void close() throws IOException {
            if (this.bos != null) {
                this.bos.close();
            }
        }
    };
}
