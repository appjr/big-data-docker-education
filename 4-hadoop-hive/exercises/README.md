# Hadoop Hive Data Warehouse Exercises

This document contains comprehensive hands-on exercises for learning Apache Hive data warehousing with Hadoop.

## Prerequisites

- Completed exercises from hadoop-ingestion image
- Understanding of HDFS, MapReduce, and SQL concepts
- Basic knowledge of data warehousing principles

## Exercise 1: Hive Installation and Environment Verification

### Objective
Verify that Hive is properly installed and configured with Derby metastore.

### Steps

1. **Start the container and verify Hive installation:**
   ```bash
   docker run -it --name hadoop-hive-test \
     -p 9870:9870 -p 8088:8088 -p 10000:10000 -p 10002:10002 \
     hadoop-hive:latest
   
   # Inside container, run verification
   cd /home/hadoop/scripts
   ./verify-hive.sh
   ```

2. **Check Hive version and components:**
   ```bash
   hive --version
   schematool -dbType derby -info
   ```

3. **Start Hive services:**
   ```bash
   # Initialize schema (first time only)
   schematool -dbType derby -initSchema
   
   # Start HiveServer2 in background
   hiveserver2 &
   
   # Wait for service to start
   sleep 10
   
   # Check if HiveServer2 is running
   netstat -tlnp | grep 10000
   ```

4. **Test Hive CLI:**
   ```bash
   # Start Hive CLI
   hive
   
   # Inside Hive CLI, run basic commands
   SHOW DATABASES;
   CREATE DATABASE test_db;
   USE test_db;
   SHOW TABLES;
   
   # Exit Hive CLI
   quit;
   ```

### Expected Results
- Hive version shows 3.1.3
- Derby metastore is initialized successfully
- HiveServer2 starts and listens on port 10000
- Can create databases and show tables

## Exercise 2: Creating Databases and Tables

### Objective
Learn to create and manage Hive databases and tables with different data types.

### Steps

1. **Create a sample database:**
   ```bash
   hive -e "
   CREATE DATABASE IF NOT EXISTS company_db
   COMMENT 'Company database for employee and department data'
   LOCATION '/user/hive/warehouse/company_db.db';
   
   SHOW DATABASES;
   DESCRIBE DATABASE company_db;
   "
   ```

2. **Create employee table with various data types:**
   ```bash
   hive -e "
   USE company_db;
   
   CREATE TABLE employees (
     emp_id INT,
     first_name STRING,
     last_name STRING,
     email STRING,
     phone_number STRING,
     hire_date DATE,
     job_id STRING,
     salary DECIMAL(8,2),
     commission_pct DECIMAL(2,2),
     manager_id INT,
     department_id INT
   )
   COMMENT 'Employee information table'
   ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
   STORED AS TEXTFILE;
   
   DESCRIBE employees;
   DESCRIBE FORMATTED employees;
   "
   ```

3. **Create departments table:**
   ```bash
   hive -e "
   USE company_db;
   
   CREATE TABLE departments (
     department_id INT,
     department_name STRING,
     manager_id INT,
     location_id INT
   )
   ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
   STORED AS TEXTFILE;
   
   SHOW TABLES;
   "
   ```

4. **Create external table:**
   ```bash
   # First create data directory in HDFS
   hdfs dfs -mkdir -p /user/hadoop/external_data
   
   hive -e "
   USE company_db;
   
   CREATE EXTERNAL TABLE external_logs (
     timestamp STRING,
     level STRING,
     message STRING
   )
   ROW FORMAT DELIMITED
   FIELDS TERMINATED BY '\t'
   STORED AS TEXTFILE
   LOCATION '/user/hadoop/external_data';
   
   DESCRIBE FORMATTED external_logs;
   "
   ```

### Expected Results
- Database 'company_db' is created successfully
- Tables are created with proper schema
- Can describe table structures and properties
- External table points to HDFS location

## Exercise 3: Data Loading and Management

### Objective
Learn different methods to load data into Hive tables from various sources.

### Steps

1. **Create sample data files:**
   ```bash
   # Create employee data
   cat > /tmp/employees.csv << 'EMPLOYEES_EOF'
   1,John,Doe,john.doe@company.com,555-1234,2020-01-15,ENGINEER,75000.00,0.00,10,100
   2,Jane,Smith,jane.smith@company.com,555-5678,2020-03-22,MANAGER,85000.00,0.10,NULL,100
   3,Bob,Johnson,bob.johnson@company.com,555-9012,2019-11-10,ENGINEER,80000.00,0.00,2,100
   4,Alice,Brown,alice.brown@company.com,555-3456,2021-02-28,ANALYST,60000.00,0.00,2,200
   5,Charlie,Wilson,charlie.wilson@company.com,555-7890,2019-08-05,ENGINEER,85000.00,0.05,2,100
   6,Diana,Davis,diana.davis@company.com,555-2468,2020-07-12,MANAGER,90000.00,0.15,NULL,200
   7,Eve,Miller,eve.miller@company.com,555-1357,2021-01-20,ANALYST,55000.00,0.00,6,200
   8,Frank,Garcia,frank.garcia@company.com,555-8642,2018-12-03,SENIOR_ENGINEER,95000.00,0.00,2,100
   EMPLOYEES_EOF
   
   # Create department data
   cat > /tmp/departments.csv << 'DEPARTMENTS_EOF'
   100,Engineering,2,1001
   200,Analytics,6,1002
   300,Sales,NULL,1003
   400,HR,NULL,1004
   DEPARTMENTS_EOF
   ```

2. **Load data using LOAD DATA command:**
   ```bash
   # Copy files to HDFS first
   hdfs dfs -put /tmp/employees.csv /tmp/
   hdfs dfs -put /tmp/departments.csv /tmp/
   
   hive -e "
   USE company_db;
   
   LOAD DATA INPATH '/tmp/employees.csv' INTO TABLE employees;
   LOAD DATA INPATH '/tmp/departments.csv' INTO TABLE departments;
   
   SELECT COUNT(*) FROM employees;
   SELECT COUNT(*) FROM departments;
   "
   ```

3. **Load data using INSERT statements:**
   ```bash
   hive -e "
   USE company_db;
   
   INSERT INTO employees VALUES 
   (9, 'Grace', 'Lee', 'grace.lee@company.com', '555-9753', '2021-06-15', 'INTERN', 35000.00, 0.00, 4, 200),
   (10, 'Henry', 'Taylor', 'henry.taylor@company.com', '555-8520', '2020-09-01', 'ENGINEER', 78000.00, 0.00, 2, 100);
   
   SELECT * FROM employees WHERE emp_id > 8;
   "
   ```

4. **Create and load partitioned table:**
   ```bash
   hive -e "
   USE company_db;
   
   CREATE TABLE employees_partitioned (
     emp_id INT,
     first_name STRING,
     last_name STRING,
     email STRING,
     phone_number STRING,
     hire_date DATE,
     job_id STRING,
     salary DECIMAL(8,2),
     commission_pct DECIMAL(2,2),
     manager_id INT
   )
   PARTITIONED BY (department_id INT)
   ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
   STORED AS TEXTFILE;
   
   -- Enable dynamic partitioning
   SET hive.exec.dynamic.partition = true;
   SET hive.exec.dynamic.partition.mode = nonstrict;
   
   INSERT OVERWRITE TABLE employees_partitioned PARTITION(department_id)
   SELECT emp_id, first_name, last_name, email, phone_number, hire_date, 
          job_id, salary, commission_pct, manager_id, department_id
   FROM employees;
   
   SHOW PARTITIONS employees_partitioned;
   "
   ```

### Expected Results
- Data is successfully loaded into tables
- Can query and count records
- Partitioned table is created with proper partitions
- Data is distributed across partitions

## Exercise 4: Basic SQL Queries and Data Analysis

### Objective
Practice fundamental SQL operations in Hive for data analysis.

### Steps

1. **Basic SELECT queries:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Select all employees
   SELECT * FROM employees LIMIT 5;
   
   -- Select specific columns
   SELECT first_name, last_name, salary FROM employees;
   
   -- Select with WHERE clause
   SELECT * FROM employees WHERE salary > 80000;
   
   -- Select with multiple conditions
   SELECT first_name, last_name, salary 
   FROM employees 
   WHERE department_id = 100 AND salary > 75000;
   "
   ```

2. **Aggregate functions:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Count employees
   SELECT COUNT(*) as total_employees FROM employees;
   
   -- Average salary
   SELECT AVG(salary) as avg_salary FROM employees;
   
   -- Min and Max salary
   SELECT MIN(salary) as min_salary, MAX(salary) as max_salary FROM employees;
   
   -- Sum of all salaries
   SELECT SUM(salary) as total_payroll FROM employees;
   "
   ```

3. **GROUP BY operations:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Group by department
   SELECT department_id, COUNT(*) as emp_count, AVG(salary) as avg_salary
   FROM employees 
   GROUP BY department_id;
   
   -- Group by job title
   SELECT job_id, COUNT(*) as count, MIN(salary) as min_sal, MAX(salary) as max_sal
   FROM employees 
   GROUP BY job_id;
   
   -- Group with HAVING clause
   SELECT department_id, AVG(salary) as avg_salary
   FROM employees 
   GROUP BY department_id
   HAVING AVG(salary) > 70000;
   "
   ```

4. **Sorting and limiting results:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Order by salary descending
   SELECT first_name, last_name, salary 
   FROM employees 
   ORDER BY salary DESC;
   
   -- Top 3 highest paid employees
   SELECT first_name, last_name, salary 
   FROM employees 
   ORDER BY salary DESC 
   LIMIT 3;
   
   -- Sort by multiple columns
   SELECT first_name, last_name, department_id, salary 
   FROM employees 
   ORDER BY department_id, salary DESC;
   "
   ```

### Expected Results
- Basic queries return correct filtered results
- Aggregate functions calculate proper statistics
- GROUP BY operations show departmental summaries
- Sorting works correctly with LIMIT clauses

## Exercise 5: Advanced SQL Operations

### Objective
Learn complex SQL operations including JOINs, subqueries, and window functions.

### Steps

1. **JOIN operations:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Inner join employees with departments
   SELECT e.first_name, e.last_name, e.salary, d.department_name
   FROM employees e
   INNER JOIN departments d ON e.department_id = d.department_id;
   
   -- Left join to include employees without departments
   SELECT e.first_name, e.last_name, e.salary, d.department_name
   FROM employees e
   LEFT JOIN departments d ON e.department_id = d.department_id;
   
   -- Self join to find employee-manager relationships
   SELECT e.first_name || ' ' || e.last_name as employee,
          m.first_name || ' ' || m.last_name as manager
   FROM employees e
   LEFT JOIN employees m ON e.manager_id = m.emp_id;
   "
   ```

2. **Subqueries:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Employees with salary above average
   SELECT first_name, last_name, salary
   FROM employees
   WHERE salary > (SELECT AVG(salary) FROM employees);
   
   -- Employees in departments with more than 2 people
   SELECT first_name, last_name, department_id
   FROM employees
   WHERE department_id IN (
     SELECT department_id 
     FROM employees 
     GROUP BY department_id 
     HAVING COUNT(*) > 2
   );
   
   -- Correlated subquery
   SELECT e1.first_name, e1.last_name, e1.salary, e1.department_id
   FROM employees e1
   WHERE e1.salary > (
     SELECT AVG(e2.salary)
     FROM employees e2
     WHERE e2.department_id = e1.department_id
   );
   "
   ```

3. **Window functions:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Rank employees by salary within department
   SELECT first_name, last_name, department_id, salary,
          RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) as salary_rank
   FROM employees;
   
   -- Running total of salaries
   SELECT first_name, last_name, salary,
          SUM(salary) OVER (ORDER BY emp_id ROWS UNBOUNDED PRECEDING) as running_total
   FROM employees
   ORDER BY emp_id;
   
   -- Lead and lag functions
   SELECT first_name, last_name, hire_date,
          LAG(hire_date, 1) OVER (ORDER BY hire_date) as prev_hire_date,
          LEAD(hire_date, 1) OVER (ORDER BY hire_date) as next_hire_date
   FROM employees
   ORDER BY hire_date;
   "
   ```

4. **Common Table Expressions (CTEs):**
   ```bash
   hive -e "
   USE company_db;
   
   -- CTE for department statistics
   WITH dept_stats AS (
     SELECT department_id, 
            COUNT(*) as emp_count,
            AVG(salary) as avg_salary,
            MAX(salary) as max_salary
     FROM employees
     GROUP BY department_id
   )
   SELECT d.department_name, ds.emp_count, ds.avg_salary, ds.max_salary
   FROM dept_stats ds
   JOIN departments d ON ds.department_id = d.department_id;
   
   -- Recursive CTE for organizational hierarchy
   WITH RECURSIVE emp_hierarchy AS (
     SELECT emp_id, first_name, last_name, manager_id, 0 as level
     FROM employees
     WHERE manager_id IS NULL
     
     UNION ALL
     
     SELECT e.emp_id, e.first_name, e.last_name, e.manager_id, eh.level + 1
     FROM employees e
     JOIN emp_hierarchy eh ON e.manager_id = eh.emp_id
   )
   SELECT * FROM emp_hierarchy ORDER BY level, emp_id;
   "
   ```

### Expected Results
- JOIN operations combine data from multiple tables correctly
- Subqueries filter and analyze data effectively
- Window functions provide analytical insights
- CTEs simplify complex query logic

## Exercise 6: Partitioning and Bucketing

### Objective
Learn advanced table organization techniques for performance optimization.

### Steps

1. **Create partitioned table by date:**
   ```bash
   hive -e "
   USE company_db;
   
   CREATE TABLE sales_data (
     sale_id INT,
     product_id INT,
     customer_id INT,
     quantity INT,
     unit_price DECIMAL(10,2),
     total_amount DECIMAL(10,2)
   )
   PARTITIONED BY (sale_date STRING)
   ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
   STORED AS TEXTFILE;
   "
   ```

2. **Load data into partitions:**
   ```bash
   # Create sample sales data
   cat > /tmp/sales_2023_01.csv << 'SALES_EOF'
   1,101,1001,2,25.50,51.00
   2,102,1002,1,45.00,45.00
   3,103,1003,3,15.75,47.25
   4,101,1004,1,25.50,25.50
   SALES_EOF
   
   cat > /tmp/sales_2023_02.csv << 'SALES_EOF'
   5,104,1005,2,35.00,70.00
   6,105,1006,1,55.25,55.25
   7,102,1007,4,45.00,180.00
   8,106,1008,2,22.75,45.50
   SALES_EOF
   
   # Upload to HDFS
   hdfs dfs -put /tmp/sales_2023_01.csv /tmp/
   hdfs dfs -put /tmp/sales_2023_02.csv /tmp/
   
   hive -e "
   USE company_db;
   
   LOAD DATA INPATH '/tmp/sales_2023_01.csv' 
   INTO TABLE sales_data PARTITION (sale_date='2023-01');
   
   LOAD DATA INPATH '/tmp/sales_2023_02.csv' 
   INTO TABLE sales_data PARTITION (sale_date='2023-02');
   
   SHOW PARTITIONS sales_data;
   "
   ```

3. **Create bucketed table:**
   ```bash
   hive -e "
   USE company_db;
   
   CREATE TABLE employees_bucketed (
     emp_id INT,
     first_name STRING,
     last_name STRING,
     email STRING,
     phone_number STRING,
     hire_date DATE,
     job_id STRING,
     salary DECIMAL(8,2),
     commission_pct DECIMAL(2,2),
     manager_id INT,
     department_id INT
   )
   CLUSTERED BY (emp_id) INTO 4 BUCKETS
   ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
   STORED AS TEXTFILE;
   
   -- Enable bucketing
   SET hive.enforce.bucketing = true;
   
   INSERT OVERWRITE TABLE employees_bucketed
   SELECT * FROM employees;
   "
   ```

4. **Query optimization with partitions and buckets:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Partition pruning
   SELECT * FROM sales_data WHERE sale_date = '2023-01';
   
   -- Bucket sampling
   SELECT * FROM employees_bucketed TABLESAMPLE(BUCKET 1 OUT OF 4);
   
   -- Join optimization with bucketed tables
   SELECT e.first_name, e.last_name, e.salary
   FROM employees_bucketed e
   WHERE e.emp_id IN (1, 2, 3, 4);
   "
   ```

### Expected Results
- Partitioned tables organize data by partition keys
- Bucketed tables distribute data evenly across buckets
- Queries benefit from partition pruning and bucket sampling
- Performance improves for large datasets

## Exercise 7: User-Defined Functions (UDFs)

### Objective
Learn to create and use custom functions in Hive.

### Steps

1. **Create simple UDF using built-in functions:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Create temporary function for full name
   CREATE TEMPORARY FUNCTION full_name AS 'org.apache.hadoop.hive.ql.udf.generic.GenericUDFConcat';
   
   SELECT emp_id, full_name(first_name, ' ', last_name) as full_name, salary
   FROM employees;
   "
   ```

2. **Use built-in string and date functions:**
   ```bash
   hive -e "
   USE company_db;
   
   -- String functions
   SELECT first_name,
          UPPER(first_name) as upper_name,
          LENGTH(first_name) as name_length,
          SUBSTR(email, 1, LOCATE('@', email) - 1) as username
   FROM employees;
   
   -- Date functions
   SELECT first_name, hire_date,
          YEAR(hire_date) as hire_year,
          MONTH(hire_date) as hire_month,
          DATEDIFF(CURRENT_DATE, hire_date) as days_employed
   FROM employees;
   "
   ```

3. **Mathematical and conditional functions:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Mathematical functions
   SELECT first_name, salary,
          ROUND(salary * 1.1, 2) as salary_with_raise,
          CASE 
            WHEN salary > 80000 THEN 'High'
            WHEN salary > 60000 THEN 'Medium'
            ELSE 'Low'
          END as salary_category
   FROM employees;
   
   -- Conditional functions
   SELECT first_name, last_name, manager_id,
          COALESCE(CAST(manager_id AS STRING), 'No Manager') as manager_status,
          IF(commission_pct > 0, 'Has Commission', 'No Commission') as commission_status
   FROM employees;
   "
   ```

4. **Aggregate UDFs:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Custom aggregations
   SELECT department_id,
          COLLECT_LIST(first_name) as employee_names,
          COLLECT_SET(job_id) as unique_jobs,
          PERCENTILE_APPROX(salary, 0.5) as median_salary
   FROM employees
   GROUP BY department_id;
   "
   ```

### Expected Results
- Built-in functions work correctly for string, date, and math operations
- Conditional logic functions provide flexible data transformation
- Aggregate functions summarize data effectively
- Custom functions extend Hive's capabilities

## Exercise 8: Integration with HDFS and MapReduce

### Objective
Understand how Hive integrates with the Hadoop ecosystem.

### Steps

1. **Explore Hive's HDFS integration:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Show table location in HDFS
   DESCRIBE FORMATTED employees;
   "
   
   # Check HDFS directly
   hdfs dfs -ls -R /user/hive/warehouse/company_db.db/
   hdfs dfs -cat /user/hive/warehouse/company_db.db/employees/employees.csv
   ```

2. **Create external table pointing to existing HDFS data:**
   ```bash
   # Create data in HDFS
   echo -e "1,Product A,Electronics\n2,Product B,Clothing\n3,Product C,Books" | hdfs dfs -put - /user/hadoop/products.csv
   
   hive -e "
   USE company_db;
   
   CREATE EXTERNAL TABLE products (
     product_id INT,
     product_name STRING,
     category STRING
   )
   ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
   STORED AS TEXTFILE
   LOCATION '/user/hadoop/';
   
   SELECT * FROM products;
   "
   ```

3. **Export Hive data to HDFS:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Export query results to HDFS
   INSERT OVERWRITE DIRECTORY '/user/hadoop/hive-export/high-earners'
   ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
   SELECT first_name, last_name, salary, department_id
   FROM employees
   WHERE salary > 75000;
   "
   
   # Check exported data
   hdfs dfs -ls /user/hadoop/hive-export/high-earners/
   hdfs dfs -cat /user/hadoop/hive-export/high-earners/000000_0
   ```

4. **Monitor MapReduce jobs:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Run a query that triggers MapReduce
   SELECT department_id, AVG(salary) as avg_salary
   FROM employees
   GROUP BY department_id;
   " &
   
   # Monitor job progress
   sleep 5
   yarn application -list
   ```

### Expected Results
- Hive tables are stored in HDFS warehouse directory
- External tables can access existing HDFS data
- Query results can be exported to HDFS
- Complex queries trigger MapReduce jobs

## Exercise 9: Performance Optimization and Troubleshooting

### Objective
Learn techniques to optimize Hive query performance and troubleshoot issues.

### Steps

1. **Query optimization techniques:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Enable optimization settings
   SET hive.exec.dynamic.partition = true;
   SET hive.exec.dynamic.partition.mode = nonstrict;
   SET hive.optimize.cp = true;
   SET hive.optimize.ppd = true;
   SET hive.vectorized.execution.enabled = true;
   
   -- Use EXPLAIN to understand query execution
   EXPLAIN SELECT e.first_name, e.last_name, d.department_name
   FROM employees e
   JOIN departments d ON e.department_id = d.department_id
   WHERE e.salary > 70000;
   "
   ```

2. **Analyze table statistics:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Analyze table for statistics
   ANALYZE TABLE employees COMPUTE STATISTICS;
   ANALYZE TABLE employees COMPUTE STATISTICS FOR COLUMNS;
   
   -- Show table statistics
   DESCRIBE FORMATTED employees;
   "
   ```

3. **Optimize file formats:**
   ```bash
   hive -e "
   USE company_db;
   
   -- Create ORC table for better performance
   CREATE TABLE employees_orc (
     emp_id INT,
     first_name STRING,
     last_name STRING,
     email STRING,
     phone_number STRING,
     hire_date DATE,
     job_id STRING,
     salary DECIMAL(8,2),
     commission_pct DECIMAL(2,2),
     manager_id INT,
     department_id INT
   )
   STORED AS ORC
   TBLPROPERTIES ('orc.compress'='SNAPPY');
   
   INSERT INTO employees_orc SELECT * FROM employees;
   
   -- Compare file sizes
   "
   
   hdfs dfs -du -h /user/hive/warehouse/company_db.db/employees/
   hdfs dfs -du -h /user/hive/warehouse/company_db.db/employees_orc/
   ```

4. **Troubleshooting common issues:**
   ```bash
   # Check Hive logs
   tail -f $HIVE_HOME/logs/hive.log
   
   # Check metastore connection
   hive -e "SHOW DATABASES;"
   
   # Verify HDFS permissions
   hdfs dfs -ls -la /user/hive/warehouse/
   
   # Check available resources
   yarn node -list
   yarn application -list
   ```

### Expected Results
- Query execution plans show optimization strategies
- Table statistics improve query planning
- ORC format provides better compression and performance
- Troubleshooting tools help identify and resolve issues

## Verification Checklist

After completing all exercises, verify:

- [ ] Hive is properly installed and configured
- [ ] Can create databases and tables with various data types
- [ ] Successfully load data from multiple sources
- [ ] Can execute basic and advanced SQL queries
- [ ] Understand JOINs, subqueries, and window functions
- [ ] Can implement partitioning and bucketing strategies
- [ ] Know how to use built-in and user-defined functions
- [ ] Understand Hive's integration with HDFS and MapReduce
- [ ] Can optimize queries and troubleshoot performance issues

## Performance Tips

1. **Table Design:**
   - Use appropriate data types
   - Implement partitioning for large tables
   - Consider bucketing for join optimization
   - Use ORC or Parquet formats for better performance

2. **Query Optimization:**
   - Use WHERE clauses to filter early
   - Leverage partition pruning
   - Enable vectorized execution
   - Use appropriate join strategies

3. **Resource Management:**
   - Monitor YARN resource usage
   - Adjust memory settings for large queries
   - Use appropriate number of reducers

## Troubleshooting Guide

**Issue: Hive metastore connection failed**
- Check Derby database initialization
- Verify metastore service is running
- Check network connectivity

**Issue: Query performance is slow**
- Analyze table statistics
- Check for proper partitioning
- Review query execution plan
- Monitor resource usage

**Issue: Out of memory errors**
- Increase JVM heap size
- Reduce data processing batch size
- Check for data skew issues

**JAVA_HOME error**
```bash
#Turn off services
pkill -f Hive
stop-dfs.sh
stop-yarn.sh

#Once services are turned off, open hadoop-env.sh file:
nano $HADOOP_HOME/etc/hadoop/hadoop-env.sh

#Add the following configuration to the bottom of the file
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

#Turn on services
start-dfs.sh
start-yarn.sh

#Double check that namenode, datanode, resourcemanager are active
jps
```
**Metastore Creation Failed**
```bash
#Make the following changes if metastore creation failed during step 3: schematool -dbType derby -initSchema

#Turn off Hive services
pkill -f Hive

#Open hive-site.xml file
nano /opt/hive/conf/hive-site.xml

#Modify the following line
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>APP</value>
    <description>Username to use against metastore database</description>
  </property>

#Add the following
<property>
	<name>datanucleus.schemaName</name>
	<value>APP</value>
</property>

#Remove old metastore
rm -rf /home/hadoop/metastore_db

#Create new metastore
schematool -dbType derby -initSchema --verbose \ -userName APP \ -url 'jdbc:derby:;databaseName=/home/hadoop/metastore_db;create=true'
```

**Java version conflict**
```bash
#If metastore creation was successful, but Hive will not start due to a Java version mismatch, downgrade to Java version 8

sudo su

apt-get update && apt-get install -y openjdk-8-jdk

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

#Check java version 
java -version

#Make permanant changes to reflect java modifications
stop-dfs.sh
stop-yarn.sh
pkill -f Hive

#Double check that services are off
jps

#Once services are turned off, open hadoop-env.sh file:
nano $HADOOP_HOME/etc/hadoop/hadoop-env.sh

#Modify the following configuration and save:
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

#Open hive-env.sh
nano /opt/hive/conf/hive-env.sh

#Edit the following line and save:
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

#Start services
start-dfs.sh
start-yarn.sh

hive --service metastore & 
hive --service hiveserver2 &

#Check services
jps

#Start Hive
Hive
```


## Next Steps

Once you've completed these exercises successfully, you're ready to move on to the Spark image, which will add advanced big data processing capabilities including machine learning and stream processing.
