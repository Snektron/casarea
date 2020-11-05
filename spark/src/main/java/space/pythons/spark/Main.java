package space.pythons.spark;

public class Main {
    public static void main(String[] args) {
        if (args.length < 3) {
            System.err.println("Expected arguments <pagerank | label> <graph.edges> <cores>");
            System.exit(1);
        }

        int cores = Integer.parseInt(args[2], 10);
        long start = System.currentTimeMillis();

        switch (args[0]) {
            case "pagerank":
                PageRank.pageRank(cores, args[1]);
                break;
            case "label":
                LabelPropagation.label(cores, args[1]);
                break;
            default:
                System.err.println("Invalid argument '" + args[0] + "'");
                System.exit(1);
        }

        long stop = System.currentTimeMillis();
        System.out.println(args[0] + ": " + (stop - start) + "ms");
    }
}
