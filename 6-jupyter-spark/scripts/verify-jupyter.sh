#!/bin/bash
# Verification script for Jupyter with Spark installation

echo "=========================================="
echo "Verifying Jupyter-Spark Installation"
echo "=========================================="

# Check Jupyter installation
echo ""
echo "1. Checking Jupyter installation..."
if command -v jupyter &> /dev/null; then
    echo "   ✓ Jupyter is installed"
    jupyter --version
else
    echo "   ✗ Jupyter is not installed"
    exit 1
fi

# Check Jupyter Lab
echo ""
echo "2. Checking Jupyter Lab..."
if command -v jupyter-lab &> /dev/null; then
    echo "   ✓ Jupyter Lab is installed"
else
    echo "   ✗ Jupyter Lab is not installed"
    exit 1
fi

# Check Python packages
echo ""
echo "3. Checking Python packages..."
REQUIRED_PACKAGES=("pyspark" "numpy" "pandas" "matplotlib" "seaborn" "sklearn" "findspark")
for package in "${REQUIRED_PACKAGES[@]}"; do
    if python3 -c "import $package" &> /dev/null; then
        echo "   ✓ $package is installed"
    else
        echo "   ✗ $package is not installed"
    fi
done

# Check Jupyter kernels
echo ""
echo "4. Checking available Jupyter kernels..."
jupyter kernelspec list

# Check Spark integration
echo ""
echo "5. Checking Spark integration..."
python3 << 'PYEOF'
try:
    import findspark
    findspark.init()
    from pyspark.sql import SparkSession
    print("   ✓ PySpark can be imported")
    
    # Test creating a Spark session
    spark = SparkSession.builder \
        .appName("VerificationTest") \
        .master("local[2]") \
        .getOrCreate()
    print("   ✓ Spark session can be created")
    
    # Test basic operation
    df = spark.range(10)
    count = df.count()
    print(f"   ✓ Basic Spark operation successful (count: {count})")
    
    spark.stop()
    print("   ✓ Spark integration verified")
except Exception as e:
    print(f"   ✗ Spark integration error: {str(e)}")
    exit(1)
PYEOF

# Check configuration files
echo ""
echo "6. Checking configuration files..."
if [ -f "/home/hadoop/.jupyter/jupyter_notebook_config.py" ]; then
    echo "   ✓ Jupyter config file exists"
else
    echo "   ✗ Jupyter config file not found"
fi

# Check directories
echo ""
echo "7. Checking directories..."
REQUIRED_DIRS=("/home/hadoop/notebooks" "/home/hadoop/notebooks/examples" "/home/hadoop/notebooks/data")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "   ✓ $dir exists"
    else
        echo "   ✗ $dir not found"
    fi
done

# Check Hadoop and Spark services
echo ""
echo "8. Checking Hadoop and Spark services..."
if command -v hdfs &> /dev/null; then
    echo "   ✓ HDFS command available"
else
    echo "   ✗ HDFS command not found"
fi

if command -v spark-submit &> /dev/null; then
    echo "   ✓ Spark submit command available"
else
    echo "   ✗ Spark submit command not found"
fi

echo ""
echo "=========================================="
echo "Verification Complete"
echo "=========================================="
echo ""
echo "To start Jupyter Lab, run:"
echo "  /home/hadoop/scripts/start-jupyter.sh"
echo ""
echo "Then access Jupyter at: http://localhost:8888"
echo "=========================================="
