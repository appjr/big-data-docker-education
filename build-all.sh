#!/bin/bash

echo "=== Building Big Data Docker Images for Education ==="
echo "This script will build all 6 Docker images in the correct order."
echo "Each image builds upon the previous one."
echo

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "Starting build process..."
echo

# Build 1: Ubuntu Java Base
echo "Building 1/6: Ubuntu Java Base..."
cd 1-ubuntu-java
if docker build -t ubuntu-java .; then
    echo "✓ Ubuntu Java Base built successfully"
else
    echo "✗ Failed to build Ubuntu Java Base"
    exit 1
fi
echo

# Build 2: Hadoop Base
echo "Building 2/6: Hadoop Base..."
cd ../2-hadoop-base
if docker build -t hadoop-base .; then
    echo "✓ Hadoop Base built successfully"
else
    echo "✗ Failed to build Hadoop Base"
    exit 1
fi
echo

# Build 3: Hadoop Ingestion
echo "Building 3/6: Hadoop Ingestion (Sqoop + Flume)..."
cd ../3-hadoop-ingestion
if docker build -t hadoop-ingestion .; then
    echo "✓ Hadoop Ingestion built successfully"
else
    echo "✗ Failed to build Hadoop Ingestion"
    exit 1
fi
echo

# Build 4: Hadoop Hive
echo "Building 4/6: Hadoop Hive..."
cd ../4-hadoop-hive
if docker build -t hadoop-hive .; then
    echo "✓ Hadoop Hive built successfully"
else
    echo "✗ Failed to build Hadoop Hive"
    exit 1
fi
echo

# Build 5: Hadoop Spark
echo "Building 5/6: Hadoop Spark..."
cd ../5-hadoop-spark
if docker build -t hadoop-spark .; then
    echo "✓ Hadoop Spark built successfully"
else
    echo "✗ Failed to build Hadoop Spark"
    exit 1
fi
echo

# Build 6: Jupyter with Spark
echo "Building 6/6: Jupyter with Spark (Interactive Data Science)..."
cd ../6-jupyter-spark
if docker build -t jupyter-spark .; then
    echo "✓ Jupyter with Spark built successfully"
else
    echo "✗ Failed to build Jupyter with Spark"
    exit 1
fi
echo

cd ..

echo "=== Build Complete! ==="
echo
echo "All Docker images have been built successfully:"
echo "  1. ubuntu-java         - Base Ubuntu with Java"
echo "  2. hadoop-base         - Hadoop HDFS + YARN + MapReduce"
echo "  3. hadoop-ingestion    - + Sqoop + Flume"
echo "  4. hadoop-hive         - + Hive + Derby"
echo "  5. hadoop-spark        - + Spark"
echo "  6. jupyter-spark       - + Jupyter Lab (Interactive data science)"
echo
echo "To run the interactive Jupyter environment:"
echo "docker run -it --name jupyter-bigdata \\"
echo "  -p 8888:8888 -p 9870:9870 -p 8088:8088 \\"
echo "  -p 4040:4040 -p 8080:8080 \\"
echo "  jupyter-spark"
echo
echo "Or to run the complete big data environment (without Jupyter):"
echo "docker run -it --name big-data-complete \\"
echo "  -p 9870:9870 -p 8088:8088 -p 19888:19888 \\"
echo "  -p 10000:10000 -p 10002:10002 \\"
echo "  -p 4040:4040 -p 18080:18080 \\"
echo "  hadoop-spark"
echo
echo "Web UIs will be available at:"
echo "  - Jupyter Lab: http://localhost:8888 (for jupyter-spark)"
echo "  - HDFS NameNode: http://localhost:9870"
echo "  - YARN ResourceManager: http://localhost:8088"
echo "  - MapReduce Job History: http://localhost:19888"
echo "  - HiveServer2 Web UI: http://localhost:10002"
echo "  - Spark Master UI: http://localhost:8080"
echo "  - Spark Application UI: http://localhost:4040 (when running)"
echo "  - Spark History Server: http://localhost:18080"
echo
