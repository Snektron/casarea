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
    public static void main(String[] args) {
        if(args.length > 1)
            return;

        JavaSparkContext context = new JavaSparkContext();

        //Get the edge list
        JavaRDD<PortableDataStream> input_map = context.binaryFiles(args[0]).values();
        JavaRDD<Tuple2<Object, Object>> edges = input_map.flatMap(x -> {
            byte[] data_arr = x.toArray();
            ArrayList<byte[]> result = new ArrayList<byte[]>();
            for(int i = 0; i < data_arr.length; i += 8) {
                result.add(Arrays.copyOfRange(data_arr, i, i+8));
            }
            return result.iterator();
        }).map(x -> {
            int source = x[0] | (x[1] >> 8) | (x[2] >> 16) | (x[3] >> 24);
            int dest = x[4] | (x[5] >> 8) | (x[6] >> 16) | (x[7] >> 24);
            return new Tuple2<Object, Object>((Integer)source, (Integer)dest);
        });

        //Construct the graph
        Graph<Object, Object> graph = Graph.fromEdgeTuples(JavaRDD.toRDD(edges),
                                            0,
                                            Option.empty(),
                                            StorageLevel.MEMORY_ONLY(),
                                            StorageLevel.MEMORY_ONLY(),
                                            scala.reflect.ClassTag$.MODULE$.apply(Integer.class));


        int max_steps = 0;
        //TODO: label propagation zoeken
    }
}