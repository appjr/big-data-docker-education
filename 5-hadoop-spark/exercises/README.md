# Hadoop Spark Big Data Processing Exercises

This document contains comprehensive hands-on exercises for learning Apache Spark with Hadoop integration.

## Prerequisites

- Completed exercises from hadoop-hive image
- Understanding of HDFS, MapReduce, Hive, and distributed computing concepts
- Basic knowledge of Scala, Python, or Java programming
- Familiarity with data processing and analytics concepts

## Exercise 1: Spark Installation and Environment Verification

### Objective
Verify that Spark is properly installed and configured with Hadoop integration.

### Steps

1. **Start the container and verify Spark installation:**
   ```bash
   docker run -it --name hadoop-spark-test \
     -p 9870:9870 -p 8088:8088 -p 4040:4040 -p 8080:8080 -p 7077:7077 \
     hadoop-spark:latest
   
   # Inside container, run verification
   cd /home/hadoop/scripts
   ./verify-spark.sh
   ```

2. **Check Spark version and components:**
   ```bash
   spark-submit --version
   spark-shell --version
   pyspark --version
   ```

3. **Start Spark services:**
   ```bash
   # Start Spark master
   start-master.sh
   
   # Start Spark worker
   start-worker.sh spark://$(hostname):7077
   
   # Check Spark processes
   jps | grep -E "(Master|Worker)"
   ```

4. **Test Spark Shell:**
   ```bash
   # Start Spark Shell (Scala)
   spark-shell --master local[2]
   
   # Inside Spark Shell, run basic commands
   val data = Array(1, 2, 3, 4, 5)
   val distData = sc.parallelize(data)
   distData.reduce((a, b) => a + b)
   
   # Exit Spark Shell
   :quit
   ```

### Expected Results
- Spark version shows 3.5.0
- Spark Master and Worker processes start successfully
- Can access Spark Web UI at http://localhost:4040 and http://localhost:8080
- Basic RDD operations work in Spark Shell

## Verification Checklist

After completing all exercises, verify:

- [ ] Spark is properly installed and configured
- [ ] Can create and manipulate RDDs
- [ ] Successfully work with DataFrames and Spark SQL
- [ ] Can execute PySpark scripts and applications
- [ ] Understand Spark Streaming concepts
- [ ] Can implement machine learning with MLlib
- [ ] Know how to integrate Spark with Hive
- [ ] Can optimize Spark applications for performance

## Troubleshooting Guide
Please see the troubleshooting guide under 4-hadoop-hive exercises to resolve common issues related to: JAVA_HOME, schematool, and Java version. 

## Next Steps

This completes the big data Docker education series. You now have comprehensive environments for learning:
1. Ubuntu + Java basics
2. Hadoop HDFS and YARN
3. Data ingestion with Sqoop and Flume
4. Data warehousing with Hive
5. Advanced processing with Spark

Each image builds upon the previous ones, providing a complete big data learning platform.
