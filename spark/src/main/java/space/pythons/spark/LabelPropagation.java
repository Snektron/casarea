package space.pythons.spark;

import java.util.*;
import org.apache.spark.api.java.*;
import org.apache.spark.api.java.function.*;
import org.apache.spark.input.*;
import org.apache.spark.graphx.*;
import org.apache.spark.graphx.lib.*;
import org.apache.spark.storage.*;
import scala.Tuple2;
import scala.Option;

class LabelPropagation {
    public static void label(String edge_dir) {
        JavaSparkContext context = new JavaSparkContext();

        var edges = context
            .binaryRecords(edge_dir, 8)
            .map(x -> {
                int source = (x[0] & 0xFF) | ((x[1] & 0xFF) << 8) | ((x[2] & 0xFF) << 16) | ((x[3] & 0xFF) << 24);
                int dest = (x[4] & 0xFF) | ((x[5] & 0xFF) << 8) | ((x[6] & 0xFF) << 16) | ((x[7] & 0xFF) << 24);
                return new Edge<Void>(source, dest, null);
            })
            .distinct()
            .cache();

        System.err.println("==== Partitions: " + edges.getNumPartitions());

        var graph = Graph.<Void, Void>fromEdges(
            edges.rdd(),
            null,
            StorageLevel.MEMORY_ONLY(),
            StorageLevel.MEMORY_ONLY(),
            scala.reflect.ClassTag$.MODULE$.apply(Void.class),
            scala.reflect.ClassTag$.MODULE$.apply(Void.class)
        ).cache();

        // Run label propagation
        int max_steps = 1;
        org.apache.spark.graphx.lib.LabelPropagation.run(
            graph,
            max_steps,
            scala.reflect.ClassTag$.MODULE$.apply(Void.class)
        );
    }
}
