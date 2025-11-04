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

## Exercise 2: RDD Operations and Transformations

### Objective
Learn to create and manipulate Resilient Distributed Datasets (RDDs), the fundamental data structure in Spark.

### Steps

1. **Create RDDs from collections:**
   ```bash
   spark-shell --master local[2]
   
   # Inside Spark Shell
   // Create RDD from a collection
   val numbers = sc.parallelize(1 to 100)
   numbers.count()
   
   // Create RDD with specific number of partitions
   val partitionedData = sc.parallelize(1 to 1000, 4)
   partitionedData.getNumPartitions
   
   // Create RDD from range
   val range = sc.range(1, 1000000, 100)
   range.take(10)
   ```

2. **Basic transformations:**
   ```scala
   // Map transformation
   val squared = numbers.map(x => x * x)
   squared.take(10)
   
   // Filter transformation
   val evenNumbers = numbers.filter(x => x % 2 == 0)
   evenNumbers.count()
   
   // FlatMap transformation
   val words = sc.parallelize(Seq("hello world", "apache spark", "big data"))
   val flatWords = words.flatMap(line => line.split(" "))
   flatWords.collect()
   
   // Distinct transformation
   val duplicates = sc.parallelize(Seq(1, 2, 2, 3, 3, 3, 4, 4, 4, 4))
   duplicates.distinct().collect()
   ```

3. **Actions on RDDs:**
   ```scala
   // Collect action (use with caution on large datasets)
   val smallData = sc.parallelize(1 to 10)
   smallData.collect()
   
   // Reduce action
   val sum = numbers.reduce((a, b) => a + b)
   println(s"Sum: $sum")
   
   // Fold action
   val product = sc.parallelize(1 to 5).fold(1)((a, b) => a * b)
   println(s"Product: $product")
   
   // Take and takeSample
   numbers.take(5)
   numbers.takeSample(false, 5)
   
   // First and top
   numbers.first()
   numbers.top(5)
   ```

4. **Pair RDD operations:**
   ```scala
   // Create pair RDD
   val pairs = sc.parallelize(Seq(
     ("apple", 1), ("banana", 2), ("apple", 3),
     ("orange", 4), ("banana", 5), ("apple", 6)
   ))
   
   // GroupByKey
   val grouped = pairs.groupByKey()
   grouped.collect().foreach(println)
   
   // ReduceByKey (preferred over groupByKey)
   val reduced = pairs.reduceByKey((a, b) => a + b)
   reduced.collect().foreach(println)
   
   // MapValues
   val doubled = pairs.mapValues(v => v * 2)
   doubled.collect().foreach(println)
   
   // Keys and values
   pairs.keys.distinct().collect()
   pairs.values.sum()
   ```

### Expected Results
- Successfully create RDDs from collections and ranges
- Transformations modify data as expected
- Actions return correct results
- Pair RDD operations aggregate data properly

## Exercise 3: DataFrames and Datasets

### Objective
Learn to work with Spark's structured APIs: DataFrames and Datasets.

### Steps

1. **Create DataFrames from various sources:**
   ```bash
   spark-shell --master local[2]
   
   # Inside Spark Shell
   import org.apache.spark.sql.SparkSession
   import org.apache.spark.sql.Row
   import org.apache.spark.sql.types._
   
   // Create DataFrame from sequence
   val data = Seq(
     (1, "John", "Engineering", 75000),
     (2, "Jane", "Marketing", 65000),
     (3, "Bob", "Engineering", 80000),
     (4, "Alice", "Sales", 70000),
     (5, "Charlie", "Engineering", 85000)
   )
   val df = data.toDF("id", "name", "department", "salary")
   df.show()
   df.printSchema()
   ```

2. **Create sample CSV data and read it:**
   ```bash
   # Exit Spark Shell first
   :quit
   
   # Create sample CSV file
   cat > /tmp/employees.csv << 'EOF'
   id,name,department,salary,hire_date
   1,John Doe,Engineering,75000,2020-01-15
   2,Jane Smith,Marketing,65000,2020-03-22
   3,Bob Johnson,Engineering,80000,2019-11-10
   4,Alice Brown,Sales,70000,2021-02-28
   5,Charlie Wilson,Engineering,85000,2019-08-05
   6,Diana Davis,HR,60000,2020-07-12
   7,Eve Miller,Marketing,68000,2021-01-20
   8,Frank Garcia,Engineering,95000,2018-12-03
   EOF
   
   # Copy to HDFS
   hdfs dfs -mkdir -p /user/hadoop/spark-data
   hdfs dfs -put /tmp/employees.csv /user/hadoop/spark-data/
   
   # Start Spark Shell and read CSV
   spark-shell --master local[2]
   
   val employeesDF = spark.read
     .option("header", "true")
     .option("inferSchema", "true")
     .csv("hdfs://localhost:9000/user/hadoop/spark-data/employees.csv")
   
   employeesDF.show()
   employeesDF.printSchema()
   ```

3. **DataFrame operations:**
   ```scala
   // Select columns
   employeesDF.select("name", "salary").show()
   
   // Filter rows
   employeesDF.filter($"salary" > 70000).show()
   employeesDF.filter($"department" === "Engineering").show()
   
   // Add new columns
   val dfWithBonus = employeesDF.withColumn("bonus", $"salary" * 0.1)
   dfWithBonus.show()
   
   // Rename columns
   val renamed = employeesDF.withColumnRenamed("name", "employee_name")
   renamed.show()
   
   // Drop columns
   employeesDF.drop("hire_date").show()
   
   // Sorting
   employeesDF.orderBy($"salary".desc).show()
   employeesDF.sort($"department", $"salary".desc).show()
   ```

4. **Aggregations and grouping:**
   ```scala
   // GroupBy and aggregate
   employeesDF.groupBy("department").count().show()
   
   employeesDF.groupBy("department")
     .agg(
       avg("salary").alias("avg_salary"),
       max("salary").alias("max_salary"),
       min("salary").alias("min_salary")
     )
     .show()
   
   // Multiple aggregations
   import org.apache.spark.sql.functions._
   
   employeesDF.groupBy("department")
     .agg(
       count("*").alias("employee_count"),
       avg("salary").alias("average_salary"),
       sum("salary").alias("total_payroll")
     )
     .orderBy($"total_payroll".desc)
     .show()
   ```

5. **Write DataFrames to different formats:**
   ```scala
   // Write as CSV
   employeesDF.write
     .option("header", "true")
     .mode("overwrite")
     .csv("hdfs://localhost:9000/user/hadoop/spark-output/employees-csv")
   
   // Write as JSON
   employeesDF.write
     .mode("overwrite")
     .json("hdfs://localhost:9000/user/hadoop/spark-output/employees-json")
   
   // Write as Parquet (columnar format)
   employeesDF.write
     .mode("overwrite")
     .parquet("hdfs://localhost:9000/user/hadoop/spark-output/employees-parquet")
   
   // Read back Parquet
   val parquetDF = spark.read.parquet("hdfs://localhost:9000/user/hadoop/spark-output/employees-parquet")
   parquetDF.show()
   ```

### Expected Results
- DataFrames are created from various sources
- Basic operations (select, filter, withColumn) work correctly
- Aggregations produce expected statistics
- Data is successfully written to different formats

## Exercise 4: Spark SQL

### Objective
Learn to use SQL queries with Spark DataFrames and integrate with Hive.

### Steps

1. **Create temporary views and run SQL queries:**
   ```scala
   // Create temporary view
   employeesDF.createOrReplaceTempView("employees")
   
   // Basic SQL queries
   spark.sql("SELECT * FROM employees").show()
   
   spark.sql("SELECT name, salary FROM employees WHERE salary > 70000").show()
   
   spark.sql("""
     SELECT department, COUNT(*) as emp_count, AVG(salary) as avg_salary
     FROM employees
     GROUP BY department
     ORDER BY avg_salary DESC
   """).show()
   ```

2. **Complex SQL operations:**
   ```scala
   // Create additional sample data
   val departmentsData = Seq(
     ("Engineering", "Tech Building", "John Smith"),
     ("Marketing", "Main Building", "Jane Doe"),
     ("Sales", "Sales Building", "Bob Johnson"),
     ("HR", "Admin Building", "Alice Brown")
   )
   val departmentsDF = departmentsData.toDF("dept_name", "location", "manager")
   departmentsDF.createOrReplaceTempView("departments")
   
   // JOIN operations
   spark.sql("""
     SELECT e.name, e.salary, e.department, d.location, d.manager
     FROM employees e
     INNER JOIN departments d ON e.department = d.dept_name
   """).show()
   
   // Subqueries
   spark.sql("""
     SELECT name, salary, department
     FROM employees
     WHERE salary > (SELECT AVG(salary) FROM employees)
   """).show()
   
   // Window functions
   spark.sql("""
     SELECT name, department, salary,
            RANK() OVER (PARTITION BY department ORDER BY salary DESC) as rank
     FROM employees
   """).show()
   
   // CTE (Common Table Expressions)
   spark.sql("""
     WITH dept_stats AS (
       SELECT department,
              AVG(salary) as avg_salary,
              COUNT(*) as emp_count
       FROM employees
       GROUP BY department
     )
     SELECT e.name, e.salary, e.department, ds.avg_salary, ds.emp_count
     FROM employees e
     JOIN dept_stats ds ON e.department = ds.department
     WHERE e.salary > ds.avg_salary
   """).show()
   ```

3. **Save query results:**
   ```scala
   // Save query result as new DataFrame
   val highEarnersDF = spark.sql("""
     SELECT name, department, salary
     FROM employees
     WHERE salary > 75000
     ORDER BY salary DESC
   """)
   
   highEarnersDF.show()
   
   // Write to Parquet
   highEarnersDF.write
     .mode("overwrite")
     .parquet("hdfs://localhost:9000/user/hadoop/spark-output/high-earners")
   ```

4. **Global temporary views:**
   ```scala
   // Create global temporary view
   employeesDF.createOrReplaceGlobalTempView("global_employees")
   
   // Access global view (note the global_temp prefix)
   spark.sql("SELECT * FROM global_temp.global_employees LIMIT 5").show()
   
   // Global views are accessible across different Spark sessions
   spark.newSession().sql("SELECT COUNT(*) FROM global_temp.global_employees").show()
   ```

### Expected Results
- Temporary views enable SQL queries on DataFrames
- Complex SQL operations (JOINs, subqueries, window functions) work correctly
- Query results can be saved as new DataFrames
- Global temporary views are accessible across sessions

## Exercise 5: Data Processing and Aggregations

### Objective
Master advanced data processing techniques including window functions, UDFs, and complex aggregations.

### Steps

1. **Window functions:**
   ```scala
   import org.apache.spark.sql.expressions.Window
   import org.apache.spark.sql.functions._
   
   // Rank within department
   val deptWindow = Window.partitionBy("department").orderBy($"salary".desc)
   
   val rankedDF = employeesDF
     .withColumn("rank", rank().over(deptWindow))
     .withColumn("dense_rank", dense_rank().over(deptWindow))
     .withColumn("row_number", row_number().over(deptWindow))
   
   rankedDF.show()
   
   // Running total
   val runningWindow = Window.orderBy("id").rowsBetween(Window.unboundedPreceding, Window.currentRow)
   
   employeesDF
     .withColumn("running_total", sum("salary").over(runningWindow))
     .show()
   
   // Moving average
   val movingWindow = Window.orderBy("id").rowsBetween(-2, 0)
   
   employeesDF
     .withColumn("moving_avg_salary", avg("salary").over(movingWindow))
     .show()
   
   // Lead and lag
   val orderWindow = Window.orderBy("salary")
   
   employeesDF
     .withColumn("next_salary", lead("salary", 1).over(orderWindow))
     .withColumn("prev_salary", lag("salary", 1).over(orderWindow))
     .show()
   ```

2. **User-Defined Functions (UDFs):**
   ```scala
   // Simple UDF
   val salaryGrade = udf((salary: Int) => {
     if (salary > 80000) "A"
     else if (salary > 70000) "B"
     else if (salary > 60000) "C"
     else "D"
   })
   
   employeesDF
     .withColumn("grade", salaryGrade($"salary"))
     .show()
   
   // UDF with multiple parameters
   val calculateBonus = udf((salary: Int, grade: String) => {
     grade match {
       case "A" => salary * 0.15
       case "B" => salary * 0.10
       case "C" => salary * 0.05
       case _ => 0.0
     }
   })
   
   employeesDF
     .withColumn("grade", salaryGrade($"salary"))
     .withColumn("bonus", calculateBonus($"salary", $"grade"))
     .show()
   
   // Register UDF for SQL
   spark.udf.register("salary_grade", salaryGrade)
   
   spark.sql("""
     SELECT name, salary, salary_grade(salary) as grade
     FROM employees
   """).show()
   ```

3. **Complex aggregations:**
   ```scala
   // Multiple aggregations with different functions
   employeesDF.agg(
     count("*").alias("total_employees"),
     sum("salary").alias("total_payroll"),
     avg("salary").alias("average_salary"),
     min("salary").alias("min_salary"),
     max("salary").alias("max_salary"),
     stddev("salary").alias("salary_stddev")
   ).show()
   
   // Collect list and set
   employeesDF
     .groupBy("department")
     .agg(
       collect_list("name").alias("employee_names"),
       collect_set("name").alias("unique_names")
     )
     .show(false)
   
   // Percentiles and quantiles
   employeesDF.stat.approxQuantile("salary", Array(0.25, 0.5, 0.75), 0.01)
   
   // Correlation and covariance
   val withYears = employeesDF.withColumn("years", year(current_date()) - year($"hire_date"))
   withYears.stat.corr("years", "salary")
   ```

4. **Joins and unions:**
   ```scala
   // Create sample bonus data
   val bonusData = Seq(
     (1, 5000),
     (3, 7000),
     (5, 8000),
     (8, 10000)
   )
   val bonusDF = bonusData.toDF("id", "bonus_amount")
   
   // Inner join
   employeesDF.join(bonusDF, Seq("id"), "inner").show()
   
   // Left outer join
   employeesDF.join(bonusDF, Seq("id"), "left").show()
   
   // Right outer join
   employeesDF.join(bonusDF, Seq("id"), "right").show()
   
   // Full outer join
   employeesDF.join(bonusDF, Seq("id"), "outer").show()
   
   // Union
   val newEmployees = Seq(
     (9, "Grace Lee", "Sales", 72000, "2023-01-10"),
     (10, "Henry Taylor", "Engineering", 78000, "2023-02-15")
   ).toDF("id", "name", "department", "salary", "hire_date")
   
   val allEmployees = employeesDF.union(newEmployees)
   allEmployees.show()
   ```

### Expected Results
- Window functions provide analytical insights
- UDFs extend DataFrame functionality
- Complex aggregations produce comprehensive statistics
- Joins and unions combine data correctly

## Exercise 6: Working with Hive Integration

### Objective
Learn to integrate Spark with Hive for seamless data warehouse operations.

### Steps

1. **Configure Spark-Hive integration:**
   ```bash
   # Start Spark Shell with Hive support
   spark-shell --master local[2] \
     --conf spark.sql.warehouse.dir=hdfs://localhost:9000/user/hive/warehouse \
     --conf spark.sql.catalogImplementation=hive
   ```

2. **Access Hive tables from Spark:**
   ```scala
   // Show Hive databases
   spark.sql("SHOW DATABASES").show()
   
   // Use specific database
   spark.sql("USE company_db")
   
   // Show tables in database
   spark.sql("SHOW TABLES").show()
   
   // Read Hive table
   val hiveEmployeesDF = spark.sql("SELECT * FROM employees")
   hiveEmployeesDF.show()
   
   // Use DataFrame API on Hive table
   val hiveTable = spark.table("employees")
   hiveTable.printSchema()
   hiveTable.filter($"salary" > 70000).show()
   ```

3. **Write Spark DataFrames to Hive:**
   ```scala
   // Create sample data
   val sparkData = Seq(
     (11, "Isaac", "Newton", "isaac.newton@company.com", "555-1111", "2023-03-15", "SCIENTIST", 100000, 0.0, null, 300),
     (12, "Marie", "Curie", "marie.curie@company.com", "555-2222", "2023-04-20", "SCIENTIST", 105000, 0.0, null, 300)
   ).toDF("emp_id", "first_name", "last_name", "email", "phone_number", "hire_date", "job_id", "salary", "commission_pct", "manager_id", "department_id")
   
   // Write to new Hive table
   sparkData.write
     .mode("overwrite")
     .saveAsTable("company_db.spark_employees")
   
   // Verify table was created
   spark.sql("SELECT * FROM company_db.spark_employees").show()
   
   // Append to existing table
   sparkData.write
     .mode("append")
     .saveAsTable("company_db.spark_employees")
   
   spark.sql("SELECT COUNT(*) FROM company_db.spark_employees").show()
   ```

4. **Create Hive tables with Spark SQL:**
   ```scala
   spark.sql("""
     CREATE TABLE IF NOT EXISTS company_db.performance_reviews (
       review_id INT,
       emp_id INT,
       review_date DATE,
       score DECIMAL(3,2),
       comments STRING
     )
     STORED AS PARQUET
   """)
   
   // Insert data
   spark.sql("""
     INSERT INTO company_db.performance_reviews VALUES
     (1, 1, '2023-06-15', 4.5, 'Excellent work'),
     (2, 2, '2023-06-16', 4.2, 'Great leadership'),
     (3, 3, '2023-06-17', 4.8, 'Outstanding performance')
   """)
   
   // Query the table
   spark.sql("SELECT * FROM company_db.performance_reviews").show()
   
   // Join Hive tables using Spark
   spark.sql("""
     SELECT e.first_name, e.last_name, e.salary, pr.score, pr.comments
     FROM company_db.employees e
     JOIN company_db.performance_reviews pr ON e.emp_id = pr.emp_id
   """).show()
   ```

5. **Partition Hive tables with Spark:**
   ```scala
   // Create partitioned table
   spark.sql("""
     CREATE TABLE IF NOT EXISTS company_db.employee_history (
       emp_id INT,
       first_name STRING,
       last_name STRING,
       salary DECIMAL(8,2)
     )
     PARTITIONED BY (year INT, department STRING)
     STORED AS PARQUET
   """)
   
   // Enable dynamic partitioning
   spark.sql("SET hive.exec.dynamic.partition = true")
   spark.sql("SET hive.exec.dynamic.partition.mode = nonstrict")
   
   // Insert with dynamic partitioning
   spark.sql("""
     INSERT INTO company_db.employee_history PARTITION(year, department)
     SELECT emp_id, first_name, last_name, salary,
            YEAR(hire_date) as year, department_id as department
     FROM company_db.employees
   """)
   
   // Show partitions
   spark.sql("SHOW PARTITIONS company_db.employee_history").show()
   ```

### Expected Results
- Spark can read and query Hive tables
- DataFrames can be saved as Hive tables
- Hive tables can be created and managed through Spark SQL
- Partitioning works correctly with dynamic partition insertion

## Exercise 7: PySpark Applications

### Objective
Learn to write and execute PySpark applications for data processing.

### Steps

1. **Create a basic PySpark script:**
   ```bash
   cat > /tmp/basic_pyspark.py << 'EOF'
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, count, sum

# Create Spark session
spark = SparkSession.builder \
    .appName("Basic PySpark Application") \
    .master("local[2]") \
    .getOrCreate()

# Sample data
data = [
    (1, "John", "Engineering", 75000),
    (2, "Jane", "Marketing", 65000),
    (3, "Bob", "Engineering", 80000),
    (4, "Alice", "Sales", 70000),
    (5, "Charlie", "Engineering", 85000)
]

# Create DataFrame
df = spark.createDataFrame(data, ["id", "name", "department", "salary"])

print("=== All Employees ===")
df.show()

print("\n=== Department Statistics ===")
df.groupBy("department") \
    .agg(
        count("*").alias("employee_count"),
        avg("salary").alias("avg_salary"),
        sum("salary").alias("total_payroll")
    ) \
    .orderBy(col("total_payroll").desc()) \
    .show()

print("\n=== High Earners (> 70000) ===")
df.filter(col("salary") > 70000) \
    .select("name", "department", "salary") \
    .orderBy(col("salary").desc()) \
    .show()

spark.stop()
EOF
   ```

2. **Run PySpark script:**
   ```bash
   # Run with spark-submit
   spark-submit --master local[2] /tmp/basic_pyspark.py
   ```

3. **Create advanced PySpark script with HDFS integration:**
   ```bash
   cat > /tmp/advanced_pyspark.py << 'EOF'
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.window import Window

# Create Spark session
spark = SparkSession.builder \
    .appName("Advanced PySpark Application") \
    .config("spark.sql.warehouse.dir", "hdfs://namenode:9000/user/hive/warehouse") \
    .enableHiveSupport() \
    .getOrCreate()

print("=== Reading from HDFS ===")
# Read CSV from HDFS
df = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv("hdfs://namenode:9000/user/hadoop/spark-data/employees.csv")

df.show()
df.printSchema()

print("\n=== Window Function Analysis ===")
# Window function - rank employees by salary within department
window_spec = Window.partitionBy("department").orderBy(col("salary").desc())

ranked_df = df.withColumn("rank", rank().over(window_spec)) \
              .withColumn("salary_percentile", percent_rank().over(window_spec))

ranked_df.show()

print("\n=== Department Analysis ===")
# Department-level analysis
dept_analysis = df.groupBy("department").agg(
    count("*").alias("emp_count"),
    avg("salary").alias("avg_salary"),
    min("salary").alias("min_salary"),
    max("salary").alias("max_salary"),
    stddev("salary").alias("salary_stddev")
).orderBy(col("avg_salary").desc())

dept_analysis.show()

print("\n=== Writing to HDFS ===")
# Write results to HDFS as Parquet
output_path = "hdfs://namenode:9000/user/hadoop/spark-output/pyspark-analysis"
dept_analysis.write \
    .mode("overwrite") \
    .parquet(output_path)

print(f"Results written to {output_path}")

# Write as CSV
dept_analysis.write \
    .option("header", "true") \
    .mode("overwrite") \
    .csv("hdfs://namenode:9000/user/hadoop/spark-output/pyspark-analysis-csv")

spark.stop()
EOF
   ```

4. **Run advanced PySpark script:**
   ```bash
   spark-submit --master local[2] /tmp/advanced_pyspark.py
   
   # Verify output in HDFS
   hdfs dfs -ls /user/hadoop/spark-output/pyspark-analysis
   hdfs dfs -cat /user/hadoop/spark-output/pyspark-analysis-csv/*.csv
   ```

5. **Create PySpark script with UDFs:**
   ```bash
   cat > /tmp/pyspark_udf.py << 'EOF'
from pyspark.sql import SparkSession
from pyspark.sql.functions import udf, col
from pyspark.sql.types import StringType, DoubleType

spark = SparkSession.builder \
    .appName("PySpark UDF Example") \
    .master("local[2]") \
    .getOrCreate()

# Read data
df = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv("hdfs://namenode:9000/user/hadoop/spark-data/employees.csv")

# Define UDF for salary grade
def get_salary_grade(salary):
    if salary > 80000:
        return "A"
    elif salary > 70000:
        return "B"
    elif salary > 60000:
        return "C"
    else:
        return "D"

# Register UDF
salary_grade_udf = udf(get_salary_grade, StringType())

# Define UDF for bonus calculation
def calculate_bonus(salary, grade):
    bonus_rates = {"A": 0.15, "B": 0.10, "C": 0.05, "D": 0.02}
    return salary * bonus_rates.get(grade, 0)

bonus_udf = udf(calculate_bonus, DoubleType())

# Apply UDFs
result_df = df.withColumn("grade", salary_grade_udf(col("salary"))) \
              .withColumn("bonus", bonus_udf(col("salary"), col("grade"))) \
              .withColumn("total_compensation", col("salary") + col("bonus"))

print("=== Employee Compensation Analysis ===")
result_df.select("name", "department", "salary", "grade", "bonus", "total_compensation") \
         .orderBy(col("total_compensation").desc()) \
         .show()

# Summary by grade
print("\n=== Summary by Grade ===")
result_df.groupBy("grade").agg(
    count("*").alias("count"),
    avg("salary").alias("avg_salary"),
    avg("bonus").alias("avg_bonus")
).orderBy("grade").show()

spark.stop()
EOF
   
   spark-submit --master local[2] /tmp/pyspark_udf.py
   ```

### Expected Results
- PySpark scripts execute successfully
- DataFrames are created and manipulated in Python
- Data is read from and written to HDFS
- UDFs work correctly in PySpark applications

## Exercise 8: Machine Learning with MLlib

### Objective
Learn to implement machine learning workflows using Spark MLlib.

### Steps

1. **Prepare data for machine learning:**
   ```bash
   # Create sample dataset for ML
   cat > /tmp/sales_data.csv << 'EOF'
advertising_spend,sales_calls,previous_customer,season,revenue
5000,100,1,1,45000
3000,80,0,1,32000
7000,120,1,2,58000
4000,90,1,1,38000
6000,110,1,3,52000
2000,70,0,2,28000
8000,150,1,3,68000
3500,85,0,1,35000
5500,105,1,2,48000
4500,95,1,1,42000
EOF
   
   # Copy to HDFS
   hdfs dfs -put /tmp/sales_data.csv /user/hadoop/spark-data/
   ```

2. **Create linear regression model:**
   ```bash
   cat > /tmp/ml_regression.py << 'EOF'
from pyspark.sql import SparkSession
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.regression import LinearRegression
from pyspark.ml.evaluation import RegressionEvaluator

spark = SparkSession.builder \
    .appName("MLlib Linear Regression") \
    .master("local[2]") \
    .getOrCreate()

# Load data
df = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv("hdfs://namenode:9000/user/hadoop/spark-data/sales_data.csv")

print("=== Sales Data ===")
df.show()
df.printSchema()

# Prepare features
assembler = VectorAssembler(
    inputCols=["advertising_spend", "sales_calls", "previous_customer", "season"],
    outputCol="features"
)

df_assembled = assembler.transform(df)
df_assembled.select("features", "revenue").show(5)

# Split data into training and testing
train_data, test_data = df_assembled.randomSplit([0.8, 0.2], seed=42)

print(f"\nTraining samples: {train_data.count()}")
print(f"Testing samples: {test_data.count()}")

# Create and train linear regression model
lr = LinearRegression(featuresCol="features", labelCol="revenue")
lr_model = lr.fit(train_data)

print("\n=== Model Coefficients ===")
print(f"Coefficients: {lr_model.coefficients}")
print(f"Intercept: {lr_model.intercept}")

# Make predictions
predictions = lr_model.transform(test_data)
predictions.select("features", "revenue", "prediction").show()

# Evaluate model
evaluator = RegressionEvaluator(
    labelCol="revenue",
    predictionCol="prediction",
    metricName="rmse"
)

rmse = evaluator.evaluate(predictions)
r2 = evaluator.setMetricName("r2").evaluate(predictions)

print("\n=== Model Performance ===")
print(f"RMSE: {rmse:.2f}")
print(f"R-squared: {r2:.4f}")

# Training summary
training_summary = lr_model.summary
print(f"\nTraining RMSE: {training_summary.rootMeanSquaredError:.2f}")
print(f"Training R2: {training_summary.r2:.4f}")

spark.stop()
EOF
   
   spark-submit --master local[2] /tmp/ml_regression.py
   ```

3. **Classification with Decision Trees:**
   ```bash
   # Create classification dataset
   cat > /tmp/customer_churn.csv << 'EOF'
customer_id,tenure_months,monthly_charges,total_charges,num_services,support_calls,churn
1,24,65.5,1572.0,3,2,0
2,6,89.2,535.2,5,5,1
3,48,45.8,2198.4,2,1,0
4,12,95.0,1140.0,6,4,1
5,36,55.3,1990.8,3,2,0
6,3,102.5,307.5,7,8,1
7,60,42.0,2520.0,2,0,0
8,9,85.7,771.3,5,6,1
9,42,48.5,2037.0,2,1,0
10,15,78.4,1176.0,4,3,1
EOF
   
   hdfs dfs -put /tmp/customer_churn.csv /user/hadoop/spark-data/
   
   cat > /tmp/ml_classification.py << 'EOF'
from pyspark.sql import SparkSession
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.classification import DecisionTreeClassifier
from pyspark.ml.evaluation import BinaryClassificationEvaluator, MulticlassClassificationEvaluator

spark = SparkSession.builder \
    .appName("MLlib Classification") \
    .master("local[2]") \
    .getOrCreate()

# Load data
df = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv("hdfs://namenode:9000/user/hadoop/spark-data/customer_churn.csv")

print("=== Customer Churn Data ===")
df.show()

# Prepare features
assembler = VectorAssembler(
    inputCols=["tenure_months", "monthly_charges", "total_charges", "num_services", "support_calls"],
    outputCol="features"
)

df_assembled = assembler.transform(df)

# Split data
train_data, test_data = df_assembled.randomSplit([0.8, 0.2], seed=42)

# Train Decision Tree Classifier
dt = DecisionTreeClassifier(featuresCol="features", labelCol="churn", maxDepth=5)
dt_model = dt.fit(train_data)

print("\n=== Feature Importances ===")
for i, importance in enumerate(dt_model.featureImportances):
    print(f"Feature {i}: {importance:.4f}")

# Make predictions
predictions = dt_model.transform(test_data)
predictions.select("customer_id", "features", "churn", "prediction", "probability").show()

# Evaluate model
binary_evaluator = BinaryClassificationEvaluator(labelCol="churn")
auc = binary_evaluator.evaluate(predictions)

multi_evaluator = MulticlassClassificationEvaluator(labelCol="churn", predictionCol="prediction")
accuracy = multi_evaluator.setMetricName("accuracy").evaluate(predictions)
precision = multi_evaluator.setMetricName("weightedPrecision").evaluate(predictions)
recall = multi_evaluator.setMetricName("weightedRecall").evaluate(predictions)

print("\n=== Model Performance ===")
print(f"AUC: {auc:.4f}")
print(f"Accuracy: {accuracy:.4f}")
print(f"Precision: {precision:.4f}")
print(f"Recall: {recall:.4f}")

spark.stop()
EOF
   
   spark-submit --master local[2] /tmp/ml_classification.py
   ```

4. **ML Pipeline with preprocessing:**
   ```bash
   cat > /tmp/ml_pipeline.py << 'EOF'
from pyspark.sql import SparkSession
from pyspark.ml import Pipeline
from pyspark.ml.feature import VectorAssembler, StandardScaler, StringIndexer
from pyspark.ml.classification import RandomForestClassifier
from pyspark.ml.evaluation import MulticlassClassificationEvaluator

spark = SparkSession.builder \
    .appName("MLlib Pipeline") \
    .master("local[2]") \
    .getOrCreate()

# Create sample data with categorical features
data = [
    ("Engineering", 75000, 5, 0),
    ("Marketing", 65000, 3, 0),
    ("Engineering", 80000, 7, 0),
    ("Sales", 70000, 4, 1),
    ("Engineering", 45000, 1, 1),
    ("Marketing", 50000, 2, 1),
    ("Sales", 85000, 8, 0),
    ("Engineering", 55000, 2, 1)
]

df = spark.createDataFrame(data, ["department", "salary", "years_experience", "left_company"])

print("=== Training Data ===")
df.show()

# Build ML pipeline
# Stage 1: Index string column
indexer = StringIndexer(inputCol="department", outputCol="department_index")

# Stage 2: Assemble features
assembler = VectorAssembler(
    inputCols=["department_index", "salary", "years_experience"],
    outputCol="raw_features"
)

# Stage 3: Scale features
scaler = StandardScaler(inputCol="raw_features", outputCol="features")

# Stage 4: Random Forest Classifier
rf = RandomForestClassifier(
    featuresCol="features",
    labelCol="left_company",
    numTrees=10,
    maxDepth=5
)

# Create pipeline
pipeline = Pipeline(stages=[indexer, assembler, scaler, rf])

# Split data
train_data, test_data = df.randomSplit([0.7, 0.3], seed=42)

# Train pipeline
print("\n=== Training Pipeline ===")
pipeline_model = pipeline.fit(train_data)

# Make predictions
predictions = pipeline_model.transform(test_data)
predictions.select("department", "salary", "years_experience", "left_company", "prediction").show()

# Evaluate
evaluator = MulticlassClassificationEvaluator(
    labelCol="left_company",
    predictionCol="prediction",
    metricName="accuracy"
)

accuracy = evaluator.evaluate(predictions)
print(f"\nPipeline Accuracy: {accuracy:.4f}")

# Save model
pipeline_model.write().overwrite().save("hdfs://namenode:9000/user/hadoop/spark-models/pipeline-model")
print("\nModel saved to HDFS")

spark.stop()
EOF
   
   spark-submit --master local[2] /tmp/ml_pipeline.py
   ```

### Expected Results
- Successfully load and prepare data for ML
- Linear regression model trains and makes predictions
- Classification models achieve reasonable accuracy
- ML pipelines automate the entire workflow
- Models can be saved and loaded from HDFS

## Exercise 9: Performance Optimization

### Objective
Learn techniques to optimize Spark application performance and troubleshoot common issues.

### Steps

1. **Understand and configure partitioning:**
   ```scala
   spark-shell --master local[2]
   
   // Create DataFrame
   val df = spark.range(1, 10000000).toDF("id")
   
   // Check default partitions
   println(s"Default partitions: ${df.rdd.getNumPartitions}")
   
   // Repartition
   val repartitioned = df.repartition(8)
   println(s"After repartition: ${repartitioned.rdd.getNumPartitions}")
   
   // Coalesce (reduces partitions without shuffle)
   val coalesced = repartitioned.coalesce(4)
   println(s"After coalesce: ${coalesced.rdd.getNumPartitions}")
   
   // Partition by column
   val employeesDF = spark.read
     .option("header", "true")
     .option("inferSchema", "true")
     .csv("hdfs://namenode:9000/user/hadoop/spark-data/employees.csv")
   
   val partitionedByDept = employeesDF.repartition($"department")
   partitionedByDept.write
     .partitionBy("department")
     .mode("overwrite")
     .parquet("hdfs://namenode:9000/user/hadoop/spark-output/partitioned-employees")
   ```

2. **Caching and persistence:**
   ```scala
   import org.apache.spark.storage.StorageLevel
   
   // Cache DataFrame in memory
   val cachedDF = employeesDF.cache()
   cachedDF.count()  // Trigger caching
   
   // Verify caching in Spark UI (Storage tab)
   cachedDF.filter($"salary" > 70000).show()
   cachedDF.groupBy("department").count().show()
   
   // Different storage levels
   val persistedDF = employeesDF.persist(StorageLevel.MEMORY_AND_DISK)
   persistedDF.count()
   
   // Unpersist when done
   cachedDF.unpersist()
   persistedDF.unpersist()
   
   // Demonstrate performance difference
   val largeDF = spark.range(1, 10000000).toDF("id")
     .withColumn("squared", $"id" * $"id")
   
   // Without caching
   val start1 = System.currentTimeMillis()
   largeDF.filter($"squared" > 1000000).count()
   largeDF.filter($"squared" > 5000000).count()
   val end1 = System.currentTimeMillis()
   println(s"Without cache: ${end1 - start1}ms")
   
   // With caching
   val cachedLarge = largeDF.cache()
   cachedLarge.count()  // Trigger caching
   
   val start2 = System.currentTimeMillis()
   cachedLarge.filter($"squared" > 1000000).count()
   cachedLarge.filter($"squared" > 5000000).count()
   val end2 = System.currentTimeMillis()
   println(s"With cache: ${end2 - start2}ms")
   
   cachedLarge.unpersist()
   ```

3. **Broadcast variables and accumulators:**
   ```scala
   // Broadcast variable for lookup data
   val departmentMap = Map(
     "Engineering" -> "TECH",
     "Marketing" -> "MKTG",
     "Sales" -> "SALES",
     "HR" -> "HR"
   )
   
   val broadcastDept = sc.broadcast(departmentMap)
   
   // Use broadcast variable in transformation
   val withDeptCode = employeesDF.rdd.map { row =>
     val dept = row.getAs[String]("department")
     val code = broadcastDept.value.getOrElse(dept, "UNKNOWN")
     (row.getAs[String]("name"), dept, code)
   }
   
   withDeptCode.take(5).foreach(println)
   
   // Accumulator for counting
   val highSalaryCount = sc.longAccumulator("HighSalaryCount")
   
   employeesDF.foreach { row =>
     val salary = row.getAs[Int]("salary")
     if (salary > 75000) {
       highSalaryCount.add(1)
     }
   }
   
   println(s"Employees with salary > 75000: ${highSalaryCount.value}")
   
   // Cleanup
   broadcastDept.destroy()
   ```

4. **Monitor and analyze with Spark UI:**
   ```bash
   # While Spark Shell is running, access Spark UI at:
   # http://localhost:4040
   
   # Run a complex query to generate interesting metrics
   ```
   
   ```scala
   val complexQuery = employeesDF
     .join(employeesDF.alias("e2"), $"department" === $"e2.department")
     .groupBy($"department")
     .agg(
       count("*").alias("count"),
       avg($"salary").alias("avg_salary")
     )
     .orderBy($"avg_salary".desc)
   
   complexQuery.show()
   
   // Check Spark UI for:
   // - Jobs tab: See job execution timeline
   // - Stages tab: View stage details and tasks
   // - Storage tab: Check cached data
   // - Environment tab: Review configuration
   // - Executors tab: Monitor resource usage
   ```

5. **Query optimization techniques:**
   ```scala
   // Enable cost-based optimization
   spark.conf.set("spark.sql.cbo.enabled", "true")
   spark.conf.set("spark.sql.adaptive.enabled", "true")
   
   // Analyze table statistics
   spark.sql("ANALYZE TABLE employees COMPUTE STATISTICS")
   
   // Use EXPLAIN to understand query plan
   val query = employeesDF
     .filter($"salary" > 70000)
     .groupBy("department")
     .agg(avg("salary").alias("avg_salary"))
   
   query.explain(true)  // Shows physical plan
   
   // Optimize joins
   // Broadcast join for small tables
   import org.apache.spark.sql.functions.broadcast
   
   val smallDF = spark.range(1, 5).toDF("dept_id")
   val optimizedJoin = employeesDF.join(broadcast(smallDF), 
     employeesDF("department") === smallDF("dept_id"))
   
   // Bucketed joins
   employeesDF.write
     .bucketBy(4, "department")
     .sortBy("salary")
     .mode("overwrite")
     .saveAsTable("bucketed_employees")
   ```

6. **Memory and resource configuration:**
   ```bash
   # Exit Spark Shell and restart with optimized settings
   :quit
   
   # Start with custom memory and executor settings
   spark-shell --master local[4] \
     --driver-memory 2g \
     --executor-memory 2g \
     --conf spark.sql.shuffle.partitions=8 \
     --conf spark.default.parallelism=8 \
     --conf spark.sql.adaptive.enabled=true \
     --conf spark.sql.adaptive.coalescePartitions.enabled=true
   ```
   
   ```scala
   // Monitor memory usage
   val df = spark.range(1, 10000000).toDF("id")
     .withColumn("value", $"id" * 2)
   
   df.cache()
   df.count()
   
   // Check memory usage in Spark UI Storage tab
   
   // Optimize shuffle partitions for your data size
   spark.conf.set("spark.sql.shuffle.partitions", "16")
   
   val aggregated = df.groupBy($"value" % 100).count()
   aggregated.explain()
   aggregated.show()
   ```

### Expected Results
- Partitioning strategies improve query performance
- Caching reduces computation time for repeated operations
- Broadcast variables optimize join operations
- Spark UI provides insights into application performance
- Query optimization techniques reduce execution time
- Proper resource configuration maximizes throughput

### Performance Tips

1. **Data Partitioning:**
   - Use appropriate number of partitions (2-4x number of cores)
   - Repartition before expensive operations
   - Use coalesce when reducing partitions

2. **Caching Strategy:**
   - Cache DataFrames that are accessed multiple times
   - Choose appropriate storage level based on data size and memory
   - Unpersist when data is no longer needed

3. **Join Optimization:**
   - Use broadcast joins for small tables (< 10MB)
   - Consider bucketing for repeated joins
   - Prefer sorting before joins when possible

4. **Resource Management:**
   - Allocate appropriate executor memory
   - Configure shuffle partitions based on data size
   - Monitor and tune garbage collection

5. **Code Optimization:**
   - Avoid collect() on large datasets
   - Use DataFrames/Datasets over RDDs when possible
   - Minimize shuffling operations
   - Filter data early in transformation pipeline

### Troubleshooting Guide

**Issue: Out of Memory Errors**
- Increase executor memory
- Reduce partition size
- Check for data skew
- Use appropriate storage level for caching

**Issue: Slow Performance**
- Check number of partitions
- Enable adaptive query execution
- Use broadcast joins for small tables
- Review Spark UI for bottlenecks

**Issue: Data Skew**
- Identify skewed keys in Spark UI
- Use salting technique for skewed joins
- Repartition data more evenly

**Issue: Too Many Small Files**
- Use coalesce before writing
- Configure appropriate partition size
- Use repartition for balanced output

## Verification Checklist

After completing all exercises, verify:

- [x] Spark is properly installed and configured
- [x] Can create and manipulate RDDs
- [x] Successfully work with DataFrames and Spark SQL
- [x] Can execute PySpark scripts and applications
- [x] Understand Spark performance optimization
- [x] Can implement machine learning with MLlib
- [x] Know how to integrate Spark with Hive
- [x] Can optimize Spark applications for performance

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
