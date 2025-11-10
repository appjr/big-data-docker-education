#!/bin/bash
# Start Jupyter Notebook/Lab with Spark integration

set -e

echo "=========================================="
echo "Starting Jupyter with Spark Integration"
echo "=========================================="

# Source Hadoop and Spark environment
if [ -f /home/hadoop/.bashrc ]; then
    source /home/hadoop/.bashrc
fi

# Ensure HDFS is running (start if needed)
echo "Checking HDFS status..."
if ! hdfs dfsadmin -report &> /dev/null; then
    echo "Starting HDFS..."
    $HADOOP_HOME/sbin/start-dfs.sh
    sleep 10
fi

# Ensure YARN is running (start if needed)
echo "Checking YARN status..."
if ! yarn node -list &> /dev/null; then
    echo "Starting YARN..."
    $HADOOP_HOME/sbin/start-yarn.sh
    sleep 10
fi

# Start Spark Master and Worker (optional, for cluster mode)
echo "Starting Spark services..."
if ! jps | grep -q "Master"; then
    $SPARK_HOME/sbin/start-master.sh
    sleep 5
fi

if ! jps | grep -q "Worker"; then
    $SPARK_HOME/sbin/start-worker.sh spark://$(hostname):7077
    sleep 5
fi

# Create necessary directories in HDFS if they don't exist
echo "Setting up HDFS directories..."
hdfs dfs -mkdir -p /user/hadoop/notebooks/data || true
hdfs dfs -mkdir -p /user/hadoop/spark-warehouse || true
hdfs dfs -chmod -R 777 /user/hadoop/notebooks || true

# Set Spark configuration for Jupyter
export PYSPARK_SUBMIT_ARGS="--master local[*] --driver-memory 2g --executor-memory 2g pyspark-shell"

# Display connection information
echo ""
echo "=========================================="
echo "Jupyter Server Information"
echo "=========================================="
echo "Jupyter Lab URL: http://localhost:8888"
echo "Spark UI URL: http://localhost:4040 (when Spark context is active)"
echo "Spark Master UI: http://localhost:8080"
echo "HDFS NameNode UI: http://localhost:9870"
echo "YARN ResourceManager UI: http://localhost:8088"
echo ""
echo "Available Kernels:"
echo "  - Python 3 (with PySpark)"
echo "  - Apache Toree - Scala"
echo "  - Apache Toree - PySpark"
echo "  - Apache Toree - SQL"
echo ""
echo "Note: No authentication required (for educational use only)"
echo "=========================================="
echo ""

# Start Jupyter Lab
echo "Starting Jupyter Lab..."
cd /home/hadoop/notebooks
exec jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token='' \
    --NotebookApp.password=''
