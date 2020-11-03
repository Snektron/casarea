package space.pythons.webgraph_extract;

import it.unimi.dsi.webgraph.BVGraph;

public class Main {
    public static void main(String[] args) throws Throwable {
        if (args.length != 1) {
            System.err.println("Missing argument: <file.graph>");
            return;
        }

        var source = args[0];
        var graph = BVGraph.load(source, 0);

        System.out.println(graph.numArcs());
    }
}
