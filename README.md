# Big Data Docker Images for Educational Purposes

This repository contains a series of Docker images designed for teaching big data technologies. Each image builds upon the previous one, creating a comprehensive learning environment for Hadoop ecosystem components.

## Image Hierarchy

```
1-ubuntu-java (Base)
    ↓
2-hadoop-base (HDFS + YARN + MapReduce)
    ↓
3-hadoop-ingestion (+ Sqoop + Flume)
    ↓
4-hadoop-hive (+ Hive + Derby)
    ↓
5-hadoop-spark (+ Spark)
    ↓
6-jupyter-spark (+ Jupyter Lab)
```

## Images Overview

### 1. Ubuntu Java Base (`1-ubuntu-java`)
- **Base**: Ubuntu 20.04 LTS
- **Components**: OpenJDK 11, basic utilities
- **Purpose**: Foundation for all Hadoop components
- **Size**: ~500MB

### 2. Hadoop Base (`2-hadoop-base`)
- **Base**: ubuntu-java
- **Components**: Hadoop 3.3.6 (HDFS, YARN, MapReduce)
- **Purpose**: Core Hadoop distributed storage and processing
- **Ports**: 9870 (HDFS), 8088 (YARN), 19888 (Job History)
- **Size**: ~1.2GB

### 3. Hadoop Ingestion (`3-hadoop-ingestion`)
- **Base**: hadoop-base
- **Components**: Sqoop 1.4.7, Flume 1.11.0
- **Purpose**: Data ingestion from databases and streaming sources
- **Additional Features**: MySQL/PostgreSQL connectors
- **Size**: ~1.4GB

### 4. Hadoop Hive (`4-hadoop-hive`)
- **Base**: hadoop-ingestion
- **Components**: Hive 3.1.3, Derby 10.14.2.0
- **Purpose**: SQL-like data warehousing on Hadoop
- **Ports**: 10000 (HiveServer2), 10002 (Hive Web UI)
- **Size**: ~1.6GB

### 5. Hadoop Spark (`5-hadoop-spark`)
- **Base**: hadoop-hive
- **Components**: Spark 3.5.7
- **Purpose**: Fast, unified analytics engine for big data
- **Ports**: 4040 (Spark UI), 18080 (History Server), 8080 (Master UI)
- **Size**: ~2.0GB

### 6. Jupyter with Spark (`6-jupyter-spark`)
- **Base**: hadoop-spark
- **Components**: Jupyter Lab, PySpark, Data Science libraries (pandas, numpy, matplotlib, seaborn, plotly)
- **Purpose**: Interactive data analysis and visualization with Spark
- **Ports**: 8888 (Jupyter Lab), plus all Spark/Hadoop ports
- **Additional Features**: Multiple kernels (Python, Scala, SQL), Apache Toree
- **Size**: ~2.5GB

## Quick Start

### Building Images

Build images in order (each depends on the previous):

```bash
# Build base image
cd 1-ubuntu-java
docker build -t ubuntu-java .

# Build Hadoop base
cd ../2-hadoop-base
docker build -t hadoop-base .

# Build ingestion layer
cd ../3-hadoop-ingestion
docker build -t hadoop-ingestion .

# Build Hive layer
cd ../4-hadoop-hive
docker build -t hadoop-hive .

# Build complete ecosystem
cd ../5-hadoop-spark
docker build -t hadoop-spark .
```

### Running Containers

#### Hadoop Base Environment
```bash
docker run -it --name hadoop-base-container \
  -p 9870:9870 -p 8088:8088 -p 19888:19888 \
  hadoop-base
```

#### Complete Big Data Environment
```bash
docker run -it --name big-data-complete \
  -p 9870:9870 -p 8088:8088 -p 19888:19888 \
  -p 10000:10000 -p 10002:10002 \
  -p 4040:4040 -p 18080:18080 \
  hadoop-spark
```

#### Interactive Jupyter Environment (Recommended for Learning)
```bash
docker run -it --name jupyter-bigdata \
  -p 8888:8888 -p 9870:9870 -p 8088:8088 \
  -p 4040:4040 -p 8080:8080 \
  jupyter-spark
```

Then access Jupyter Lab at: **http://localhost:8888** (no password required)

## Web Interfaces

Once containers are running, access these web UIs:

| Service | URL | Description |
|---------|-----|-------------|
| HDFS NameNode | http://localhost:9870 | HDFS cluster overview |
| YARN ResourceManager | http://localhost:8088 | YARN applications and cluster resources |
| MapReduce Job History | http://localhost:19888 | Historical job information |
| HiveServer2 Web UI | http://localhost:10002 | Hive server status and configuration |
| Spark History Server | http://localhost:18080 | Spark application history |
| Spark Application UI | http://localhost:4040 | Live Spark application monitoring |

## Educational Exercises

Each image includes comprehensive exercises in the `exercises/` directory:

### Hadoop Base Exercises
- HDFS operations and file management
- MapReduce job execution
- YARN application monitoring
- Cluster administration basics

### Ingestion Exercises
- Sqoop database imports/exports
- Flume streaming data ingestion
- Data pipeline creation
- Real-time data processing

### Hive Exercises
- SQL-like queries on big data
- Table creation and management
- Partitioning and bucketing
- Performance optimization

### Spark Exercises
- RDD operations and transformations
- Spark SQL and DataFrames
- Machine learning with MLlib
- Streaming data processing

## Sample Commands

### HDFS Operations
```bash
# List HDFS contents
hdfs dfs -ls /

# Create directory
hdfs dfs -mkdir /user/data

# Upload file
hdfs dfs -put localfile.txt /user/data/

# Download file
hdfs dfs -get /user/data/file.txt ./
```

### MapReduce
```bash
# Run word count example
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  wordcount /input /output
```

### Hive
```bash
# Start Hive CLI
hive

# Create table
CREATE TABLE students (id INT, name STRING, age INT);

# Query data
SELECT * FROM students WHERE age > 20;
```

### Spark
```bash
# Start Spark shell
spark-shell

# Run Spark example
run-example SparkPi 10

# Start PySpark
pyspark
```

## System Requirements

### Minimum Requirements
- **RAM**: 4GB (8GB recommended)
- **CPU**: 2 cores (4 cores recommended)
- **Disk**: 10GB free space
- **Docker**: Version 20.10+

### Recommended for Production Learning
- **RAM**: 8-16GB
- **CPU**: 4-8 cores
- **Disk**: 20GB+ free space
- **Network**: Stable internet for downloads

## Troubleshooting

### Common Issues

**Container exits immediately**
- Check available memory (containers need 2-4GB RAM)
- Verify all required ports are available

**Services not starting**
- Wait longer for services to initialize (can take 2-3 minutes)
- Check logs: `docker logs <container-name>`

**Web UIs not accessible**
- Verify port mappings in docker run command
- Check firewall settings
- Ensure services are fully started

**Out of memory errors**
- Increase Docker memory allocation
- Reduce number of concurrent containers
- Use smaller heap sizes in configuration

### Performance Optimization

**For better performance:**
- Allocate more memory to Docker
- Use SSD storage for Docker volumes
- Increase CPU allocation
- Close unnecessary applications

## Educational Use Cases

### Course Integration
- **Big Data Fundamentals**: Start with hadoop-base
- **Data Engineering**: Use hadoop-ingestion
- **Data Warehousing**: Progress to hadoop-hive
- **Advanced Analytics**: Complete with hadoop-spark

### Lab Exercises
- Individual student containers
- Shared cluster simulations
- Real-world data processing scenarios
- Performance benchmarking

### Assessment Ideas
- HDFS file management tasks
- MapReduce job optimization
- SQL query performance on big data
- Spark application development

## Contributing

To contribute to this educational project:

1. Fork the repository
2. Create feature branch
3. Add exercises or improvements
4. Test with students
5. Submit pull request

## License

This project is designed for educational purposes. All included software components maintain their respective licenses:
- Apache Hadoop: Apache License 2.0
- Apache Spark: Apache License 2.0
- Apache Hive: Apache License 2.0
- Apache Sqoop: Apache License 2.0
- Apache Flume: Apache License 2.0

## Support

For educational support:
- Check exercise README files in each image directory
- Review troubleshooting guides
- Consult official documentation for each component

## Version Information

| Component | Version | Notes |
|-----------|---------|-------|
| Ubuntu | 20.04 LTS | Base operating system |
| OpenJDK | 11 | Java runtime |
| Hadoop | 3.3.6 | Core big data platform |
| Spark | 3.5.7 | Analytics engine |
| Hive | 3.1.3 | Data warehouse |
| Sqoop | 1.4.7 | Data transfer tool |
| Flume | 1.11.0 | Data ingestion |
| Derby | 10.14.2.0 | Embedded database |

---

**Created for Big Data Education**  
*Helping students learn distributed computing and big data technologies through hands-on experience*
