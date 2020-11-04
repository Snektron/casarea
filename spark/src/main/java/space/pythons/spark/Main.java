package space.pythons.spark;

public class Main {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("Expected arguments <pagerank | label> <graph.edges>");
            System.exit(1);
        }

        switch (args[0]) {
            case "pagerank":
                PageRank.pageRank(args[1]);
                break;
            case "label":
                LabelPropagation.label(args[1]);
                break;
            default:
                System.err.println("Invalid argument '" + args[0] + "'");
                System.exit(1);
        }
    }
}
