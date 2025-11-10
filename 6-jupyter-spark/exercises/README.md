# Jupyter with Spark Interactive Data Analysis Exercises

This document contains comprehensive hands-on exercises for learning interactive big data analysis using Jupyter notebooks with Spark integration.

## Prerequisites

- Completed exercises from hadoop-spark image
- Understanding of Spark DataFrames, SQL, and PySpark
- Basic knowledge of Jupyter notebooks
- Familiarity with Python data science libraries (pandas, matplotlib, numpy)

## Exercise 1: Jupyter-Spark Installation and Environment Verification

### Objective
Verify that Jupyter is properly installed and configured with Spark integration.

### Steps

1. **Start the container and verify installation:**
   ```bash
   docker run -it --name jupyter-spark-test \
     -p 8888:8888 -p 4040:4040 -p 8080:8080 \
     -p 9870:9870 -p 8088:8088 \
     jupyter-spark:latest
   
   # Inside container, run verification
   cd /home/hadoop/scripts
   ./verify-jupyter.sh
   ```

2. **Access Jupyter Lab:**
   - Open browser and navigate to: http://localhost:8888
   - You should see the Jupyter Lab interface
   - No password or token required (educational setup)

3. **Check available kernels:**
   - In Jupyter Lab, click the "+" button to create a new notebook
   - You should see multiple kernel options:
     - Python 3
     - Apache Toree - Scala
     - Apache Toree - PySpark
     - Apache Toree - SQL

4. **Create a test notebook (Python 3 kernel):**
   ```python
   # Test 1: Import libraries
   import findspark
   findspark.init()
   
   from pyspark.sql import SparkSession
   import pandas as pd
   import numpy as np
   import matplotlib.pyplot as plt
   
   print("All imports successful!")
   
   # Test 2: Create Spark session
   spark = SparkSession.builder \
       .appName("JupyterTest") \
       .master("local[*]") \
       .getOrCreate()
   
   print(f"Spark version: {spark.version}")
   print(f"Spark UI: http://localhost:4040")
   
   # Test 3: Basic Spark operation
   df = spark.range(100)
   count = df.count()
   print(f"DataFrame count: {count}")
   
   # Test 4: Convert to Pandas
   pandas_df = df.toPandas()
   print(f"Pandas DataFrame shape: {pandas_df.shape}")
   print(pandas_df.head())
   ```

### Expected Results
- Jupyter Lab loads successfully at http://localhost:8888
- Multiple Jupyter kernels are available
- Can create and run notebooks
- Spark session is created successfully
- Can access Spark UI at http://localhost:4040
- All Python libraries import without errors

## Exercise 2: Interactive Data Exploration with PySpark

### Objective
Learn to use Jupyter notebooks for interactive data exploration using PySpark DataFrames.

### Steps

1. **Create a new notebook and load sample data:**
   ```python
   from pyspark.sql import SparkSession
   from pyspark.sql.functions import *
   import findspark
   findspark.init()
   
   # Create Spark session
   spark = SparkSession.builder \
       .appName("DataExploration") \
       .config("spark.sql.warehouse.dir", "hdfs://namenode:9000/user/hive/warehouse") \
       .enableHiveSupport() \
       .getOrCreate()
   
   # Create sample employee data
   data = [
       (1, "John Doe", "Engineering", 75000, "2020-01-15", 5),
       (2, "Jane Smith", "Marketing", 65000, "2020-03-22", 3),
       (3, "Bob Johnson", "Engineering", 80000, "2019-11-10", 7),
       (4, "Alice Brown", "Sales", 70000, "2021-02-28", 4),
       (5, "Charlie Wilson", "Engineering", 85000, "2019-08-05", 8),
       (6, "Diana Davis", "HR", 60000, "2020-07-12", 3),
       (7, "Eve Miller", "Marketing", 68000, "2021-01-20", 2),
       (8, "Frank Garcia", "Engineering", 95000, "2018-12-03", 10)
   ]
   
   columns = ["id", "name", "department", "salary", "hire_date", "years_experience"]
   df = spark.createDataFrame(data, columns)
   
   # Display DataFrame
   df.show()
   ```

2. **Explore DataFrame structure:**
   ```python
   # Schema
   df.printSchema()
   
   # Column names
   print("Columns:", df.columns)
   
   # Row count
   print("Row count:", df.count())
   
   # Data types
   print("Data types:", df.dtypes)
   
   # Summary statistics
   df.describe().show()
   
   # Specific column stats
   df.select(
       mean('salary').alias('mean_salary'),
       stddev('salary').alias('stddev_salary'),
       min('salary').alias('min_salary'),
       max('salary').alias('max_salary')
   ).show()
   ```

3. **Interactive filtering and selection:**
   ```python
   # Filter high earners
   high_earners = df.filter(col('salary') > 75000)
   high_earners.show()
   
   # Select specific columns
   df.select('name', 'department', 'salary').show()
   
   # Multiple conditions
   eng_high_earners = df.filter(
       (col('department') == 'Engineering') & 
       (col('salary') > 80000)
   )
   eng_high_earners.show()
   
   # Sort by salary
   df.orderBy(col('salary').desc()).show()
   ```

4. **Aggregations and grouping:**
   ```python
   # Group by department
   dept_stats = df.groupBy('department').agg(
       count('*').alias('employee_count'),
       avg('salary').alias('avg_salary'),
       max('salary').alias('max_salary'),
       min('salary').alias('min_salary')
   )
   dept_stats.show()
   
   # Experience analysis
   exp_stats = df.groupBy('years_experience').agg(
       count('*').alias('count'),
       avg('salary').alias('avg_salary')
   ).orderBy('years_experience')
   exp_stats.show()
   ```

5. **Save intermediate results:**
   ```python
   # Save to HDFS as Parquet
   df.write.mode('overwrite').parquet('hdfs://namenode:9000/user/hadoop/notebooks/data/employees.parquet')
   
   # Read it back
   df_read = spark.read.parquet('hdfs://namenode:9000/user/hadoop/notebooks/data/employees.parquet')
   df_read.show()
   ```

### Expected Results
- Can create and manipulate DataFrames interactively
- All DataFrame operations execute successfully
- Results are displayed inline in the notebook
- Can save and reload data from HDFS
- Spark UI shows job execution details

## Exercise 3: Data Visualization in Jupyter

### Objective
Learn to create visualizations of Spark data using matplotlib, seaborn, and plotly.

### Steps

1. **Setup visualization libraries:**
   ```python
   import matplotlib.pyplot as plt
   import seaborn as sns
   import plotly.express as px
   import plotly.graph_objects as go
   from pyspark.sql import SparkSession
   from pyspark.sql.functions import *
   import pandas as pd
   
   # Set style
   sns.set_style('whitegrid')
   plt.rcParams['figure.figsize'] = (12, 6)
   
   # Enable inline plotting
   %matplotlib inline
   ```

2. **Create visualizations with matplotlib:**
   ```python
   # Convert Spark DataFrame to Pandas for plotting
   pandas_df = df.toPandas()
   
   # Salary distribution by department
   fig, axes = plt.subplots(1, 2, figsize=(15, 5))
   
   # Box plot
   pandas_df.boxplot(column='salary', by='department', ax=axes[0])
   axes[0].set_title('Salary Distribution by Department')
   axes[0].set_xlabel('Department')
   axes[0].set_ylabel('Salary')
   
   # Bar chart of average salaries
   dept_avg = pandas_df.groupby('department')['salary'].mean().sort_values()
   dept_avg.plot(kind='barh', ax=axes[1], color='skyblue')
   axes[1].set_title('Average Salary by Department')
   axes[1].set_xlabel('Average Salary')
   
   plt.tight_layout()
   plt.show()
   ```

3. **Advanced visualizations with seaborn:**
   ```python
   # Scatter plot: Experience vs Salary
   plt.figure(figsize=(10, 6))
   sns.scatterplot(data=pandas_df, x='years_experience', y='salary', 
                    hue='department', size='salary', sizes=(100, 400))
   plt.title('Salary vs Years of Experience by Department')
   plt.xlabel('Years of Experience')
   plt.ylabel('Salary')
   plt.show()
   
   # Violin plot
   plt.figure(figsize=(12, 6))
   sns.violinplot(data=pandas_df, x='department', y='salary')
   plt.title('Salary Distribution by Department (Violin Plot)')
   plt.xticks(rotation=45)
   plt.show()
   
   # Correlation heatmap
   numeric_cols = pandas_df[['salary', 'years_experience']]
   plt.figure(figsize=(8, 6))
   sns.heatmap(numeric_cols.corr(), annot=True, cmap='coolwarm', center=0)
   plt.title('Correlation Matrix')
   plt.show()
   ```

4. **Interactive visualizations with plotly:**
   ```python
   # Interactive scatter plot
   fig = px.scatter(pandas_df, 
                    x='years_experience', 
                    y='salary',
                    color='department',
                    size='salary',
                    hover_data=['name'],
                    title='Interactive: Salary vs Experience')
   fig.show()
   
   # Interactive bar chart
   dept_stats_pd = dept_stats.toPandas()
   fig = px.bar(dept_stats_pd, 
                x='department', 
                y='avg_salary',
                title='Average Salary by Department',
                text='employee_count')
   fig.update_traces(texttemplate='%{text} employees', textposition='outside')
   fig.show()
   
   # Sunburst chart
   fig = go.Figure(go.Sunburst(
       labels=['Company'] + pandas_df['department'].tolist(),
       parents=[''] + ['Company'] * len(pandas_df),
       values=[pandas_df['salary'].sum()] + pandas_df['salary'].tolist(),
       text=pandas_df['name'].tolist()
   ))
   fig.update_layout(title='Salary Distribution Hierarchy')
   fig.show()
   ```

### Expected Results
- Static and interactive visualizations render inline
- Matplotlib and seaborn charts display correctly
- Plotly visualizations are interactive
- Can zoom, pan, and hover over interactive plots
- Charts provide clear insights into data patterns

## Exercise 4: SQL Queries in Jupyter

### Objective
Use Spark SQL within Jupyter notebooks for interactive data analysis.

### Steps

1. **Register DataFrame as temporary view:**
   ```python
   # Create or reuse Spark session
   from pyspark.sql import SparkSession
   spark = SparkSession.builder.appName("SQLQueries").getOrCreate()
   
   # Register as temp view
   df.createOrReplaceTempView("employees")
   
   # Run SQL query
   result = spark.sql("SELECT * FROM employees WHERE salary > 70000")
   result.show()
   ```

2. **Use SQL magic commands (with Toree - SQL kernel):**
   Create a new notebook with "Apache Toree - SQL" kernel:
   ```sql
   -- Select all employees
   SELECT * FROM employees;
   
   -- Department statistics
   SELECT 
       department,
       COUNT(*) as employee_count,
       AVG(salary) as avg_salary,
       MAX(salary) as max_salary,
       MIN(salary) as min_salary
   FROM employees
   GROUP BY department
   ORDER BY avg_salary DESC;
   
   -- Top earners
   SELECT name, department, salary
   FROM employees
   ORDER BY salary DESC
   LIMIT 3;
   ```

3. **Complex SQL queries in Python notebook:**
   ```python
   # JOIN with another dataset
   dept_budgets = spark.createDataFrame([
       ('Engineering', 500000),
       ('Marketing', 300000),
       ('Sales', 400000),
       ('HR', 200000)
   ], ['department', 'budget'])
   
   dept_budgets.createOrReplaceTempView("dept_budgets")
   
   # Complex query with JOIN and aggregation
   query = """
   SELECT 
       e.department,
       COUNT(e.id) as employee_count,
       SUM(e.salary) as total_payroll,
       b.budget,
       (b.budget - SUM(e.salary)) as remaining_budget,
       ROUND((SUM(e.salary) / b.budget) * 100, 2) as budget_utilization
   FROM employees e
   JOIN dept_budgets b ON e.department = b.department
   GROUP BY e.department, b.budget
   ORDER BY budget_utilization DESC
   """
   
   result = spark.sql(query)
   result.show()
   
   # Visualize results
   result_pd = result.toPandas()
   
   fig, ax = plt.subplots(figsize=(12, 6))
   x = range(len(result_pd))
   width = 0.35
   
   ax.bar([i - width/2 for i in x], result_pd['total_payroll'], width, label='Payroll')
   ax.bar([i + width/2 for i in x], result_pd['budget'], width, label='Budget')
   
   ax.set_xlabel('Department')
   ax.set_ylabel('Amount ($)')
   ax.set_title('Department Budget vs Payroll')
   ax.set_xticks(x)
   ax.set_xticklabels(result_pd['department'])
   ax.legend()
   plt.xticks(rotation=45)
   plt.tight_layout()
   plt.show()
   ```

4. **Window functions in SQL:**
   ```python
   query = """
   SELECT 
       name,
       department,
       salary,
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank,
       DENSE_RANK() OVER (ORDER BY salary DESC) as company_rank,
       LAG(salary) OVER (PARTITION BY department ORDER BY salary) as prev_salary,
       LEAD(salary) OVER (PARTITION BY department ORDER BY salary) as next_salary
   FROM employees
   """
   
   spark.sql(query).show()
   ```

### Expected Results
- SQL queries execute successfully in notebooks
- Can mix SQL and Python code seamlessly
- Results can be easily visualized
- SQL magic commands work in Toree kernel
- Complex queries with JOINs and window functions work correctly

## Exercise 5: Machine Learning Workflows in Jupyter

### Objective
Build and evaluate machine learning models interactively using Spark MLlib.

### Steps

1. **Prepare data for ML:**
   ```python
   from pyspark.ml.feature import VectorAssembler, StandardScaler
   from pyspark.ml.regression import LinearRegression
   from pyspark.ml.evaluation import RegressionEvaluator
   from pyspark.ml import Pipeline
   import numpy as np
   
   # Create larger dataset for ML
   np.random.seed(42)
   n_samples = 1000
   
   ml_data = [(
       int(i),
       np.random.choice(['Engineering', 'Marketing', 'Sales', 'HR']),
       int(np.random.randint(1, 15)),
       int(np.random.randint(0, 2)),
       int(np.random.randint(40000, 120000))
   ) for i in range(n_samples)]
   
   ml_df = spark.createDataFrame(ml_data, 
       ['id', 'department', 'years_exp', 'has_degree', 'salary'])
   
   ml_df.show(10)
   ml_df.describe().show()
   ```

2. **Build ML pipeline:**
   ```python
   from pyspark.ml.feature import StringIndexer, OneHotEncoder
   
   # Index categorical column
   indexer = StringIndexer(inputCol='department', outputCol='dept_index')
   
   # One-hot encode
   encoder = OneHotEncoder(inputCols=['dept_index'], 
                           outputCols=['dept_encoded'])
   
   # Assemble features
   assembler = VectorAssembler(
       inputCols=['dept_encoded', 'years_exp', 'has_degree'],
       outputCol='features'
   )
   
   # Scale features
   scaler = StandardScaler(inputCol='features', 
                           outputCol='scaled_features')
   
   # Create model
   lr = LinearRegression(featuresCol='scaled_features', 
                         labelCol='salary')
   
   # Build pipeline
   pipeline = Pipeline(stages=[indexer, encoder, assembler, scaler, lr])
   
   # Split data
   train_df, test_df = ml_df.randomSplit([0.8, 0.2], seed=42)
   
   print(f"Training samples: {train_df.count()}")
   print(f"Testing samples: {test_df.count()}")
   ```

3. **Train and evaluate model:**
   ```python
   # Train model
   model = pipeline.fit(train_df)
   
   # Make predictions
   predictions = model.transform(test_df)
   
   # Show predictions
   predictions.select('id', 'department', 'years_exp', 
                      'has_degree', 'salary', 'prediction').show(10)
   
   # Evaluate model
   evaluator = RegressionEvaluator(
       labelCol='salary',
       predictionCol='prediction',
       metricName='rmse'
   )
   
   rmse = evaluator.evaluate(predictions)
   r2 = evaluator.setMetricName('r2').evaluate(predictions)
   mae = evaluator.setMetricName('mae').evaluate(predictions)
   
   print(f"RMSE: ${rmse:,.2f}")
   print(f"R²: {r2:.4f}")
   print(f"MAE: ${mae:,.2f}")
   ```

4. **Visualize model performance:**
   ```python
   # Convert to pandas for visualization
   pred_pd = predictions.select('salary', 'prediction').toPandas()
   
   # Actual vs Predicted
   plt.figure(figsize=(10, 6))
   plt.scatter(pred_pd['salary'], pred_pd['prediction'], alpha=0.5)
   plt.plot([pred_pd['salary'].min(), pred_pd['salary'].max()], 
            [pred_pd['salary'].min(), pred_pd['salary'].max()], 
            'r--', lw=2, label='Perfect Prediction')
   plt.xlabel('Actual Salary')
   plt.ylabel('Predicted Salary')
   plt.title('Actual vs Predicted Salaries')
   plt.legend()
   plt.tight_layout()
   plt.show()
   
   # Residuals plot
   pred_pd['residuals'] = pred_pd['salary'] - pred_pd['prediction']
   
   plt.figure(figsize=(10, 6))
   plt.scatter(pred_pd['prediction'], pred_pd['residuals'], alpha=0.5)
   plt.axhline(y=0, color='r', linestyle='--')
   plt.xlabel('Predicted Salary')
   plt.ylabel('Residuals')
   plt.title('Residuals Plot')
   plt.tight_layout()
   plt.show()
   ```

5. **Feature importance analysis:**
   ```python
   # Get linear regression model from pipeline
   lr_model = model.stages[-1]
   
   # Get feature names
   feature_names = ['dept_Engineering', 'dept_HR', 'dept_Marketing', 
                    'dept_Sales', 'years_exp', 'has_degree']
   
   # Get coefficients
   coefficients = lr_model.coefficients.toArray()
   
   # Create DataFrame
   importance_df = pd.DataFrame({
       'feature': feature_names,
       'coefficient': coefficients,
       'abs_coefficient': np.abs(coefficients)
   }).sort_values('abs_coefficient', ascending=False)
   
   # Plot
   plt.figure(figsize=(10, 6))
   plt.barh(importance_df['feature'], importance_df['coefficient'])
   plt.xlabel('Coefficient Value')
   plt.title('Feature Importance (Linear Regression Coefficients)')
   plt.tight_layout()
   plt.show()
   
   print(importance_df)
   ```

### Expected Results
- ML pipeline builds successfully
- Model trains and makes predictions
- Evaluation metrics are calculated correctly
- Visualizations show model performance
- Can iterate and improve model interactively

## Exercise 6: Working with Large Datasets

### Objective
Learn best practices for working with large datasets in Jupyter with Spark.

### Steps

1. **Generate and work with larger datasets:**
   ```python
   # Generate 1 million records
   large_df = spark.range(1000000).toDF('id')
   
   from pyspark.sql.functions import rand, randn, when, col
   
   large_df = large_df.select(
       col('id'),
       (rand() * 100).cast('int').alias('value1'),
       (randn() * 50 + 100).cast('int').alias('value2'),
       when(rand() > 0.5, 'A').otherwise('B').alias('category')
   )
   
   print(f"Dataset size: {large_df.count():,} rows")
   large_df.show(10)
   ```

2. **Efficient sampling for exploration:**
   ```python
   # Sample for quick exploration
   sample_df = large_df.sample(fraction=0.01, seed=42)
   print(f"Sample size: {sample_df.count():,} rows")
   
   # Convert sample to Pandas for quick viz
   sample_pd = sample_df.toPandas()
   
   # Quick visualization
   fig, axes = plt.subplots(2, 2, figsize=(15, 10))
   
   sample_pd['value1'].hist(bins=50, ax=axes[0,0])
   axes[0,0].set_title('Value1 Distribution')
   
   sample_pd['value2'].hist(bins=50, ax=axes[0,1])
   axes[0,1].set_title('Value2 Distribution')
   
   sample_pd.boxplot(column='value1', by='category', ax=axes[1,0])
   axes[1,0].set_title('Value1 by Category')
   
   sample_pd.plot(kind='scatter', x='value1', y='value2', 
                  c='category', ax=axes[1,1], colormap='viridis', alpha=0.5)
   axes[1,1].set_title('Value1 vs Value2')
   
   plt.tight_layout()
   plt.show()
   ```

3. **Caching for iterative analysis:**
   ```python
   # Cache for repeated use
   large_df.cache()
   large_df.count()  #Trigger caching
   
   # Multiple operations on cached data
   stats = large_df.groupBy('category').agg(
       count('*').alias('count'),
       avg('value1').alias('avg_value1'),
       avg('value2').alias('avg_value2')
   )
   stats.show()
   
   # Check cache status
   print(f"Is cached: {large_df.is_cached}")
   
   # Unpersist when done
   large_df.unpersist()
   ```

4. **Partitioning strategies:**
   ```python
   # Check current partitions
   print(f"Current partitions: {large_df.rdd.getNumPartitions()}")
   
   # Repartition for better performance
   large_df_repartitioned = large_df.repartition(8, 'category')
   print(f"After repartition: {large_df_repartitioned.rdd.getNumPartitions()}")
   
   # Analyze partition distribution
   partition_counts = large_df_repartitioned.rdd.mapPartitions(
       lambda partition: [sum(1 for _ in partition)]
   ).collect()
   
   plt.figure(figsize=(10, 6))
   plt.bar(range(len(partition_counts)), partition_counts)
   plt.xlabel('Partition')
   plt.ylabel('Record Count')
   plt.title('Records per Partition')
   plt.show()
   ```

5. **Monitoring Spark jobs:**
   ```python
   # Run operation and monitor in Spark UI
   result = large_df.groupBy('category').agg(
       count('*').alias('total'),
       avg('value1').alias('avg_v1'),
       avg('value2').alias('avg_v2'),
       min('value1').alias('min_v1'),
       max('value1').alias('max_v1')
   )
   
   result.show()
   
   print("\nCheck Spark UI at http://localhost:4040")
   print("- View SQL tab for query execution plan")
   print("- View Stages tab for task details")
   print("- View Storage tab for cached data")
   ```

### Expected Results
- Can generate and work with large datasets
- Sampling provides quick insights
- Caching improves performance for iterative operations
-Partitioning strategies optimize processing
- Spark UI shows detailed execution metrics

## Verification Checklist

After completing all exercises, verify:

- [x] Jupyter Lab is accessible and working
- [x] Multiple kernels (Python, Scala, SQL) are available
- [x] Can create Spark sessions in notebooks
- [x] Interactive data exploration works smoothly
- [x] Data visualizations render correctly
- [x] SQL queries execute successfully
- [x] Machine learning pipelines can be built and evaluated
- [x] Can work with large datasets efficiently
- [x] Spark UI provides execution insights

## Tips for Jupyter-Spark Development

1. **Session Management:**
   - Always stop Spark sessions when done: `spark.stop()`
   - Restart kernel to clear memory if needed
   - Monitor resource usage in Spark UI

2. **Data Conversion:**
   - Convert to Pandas only for small datasets or samples
   - Use `.toPandas()` judiciously to avoid memory issues
   - Prefer Spark operations for large-scale processing

3. **Visualization Best Practices:**
   - Sample large datasets before visualization
   - Use interactive plots (Plotly) for exploration
   - Save static plots (matplotlib/seaborn) for reports

4. **Performance:**
   - Cache DataFrames that are reused multiple times
   - Use partitioning strategies for large datasets
   - Monitor execution plans in Spark UI
   - Avoid shuffles when possible

5. **Code Organization:**
   - Use markdown cells for documentation
   - Break long operations into multiple cells
   - Add comments and explanations
   - Keep notebooks focused and modular

6. **Collaboration:**
   - Version control notebooks with Git
   - Export notebooks as HTML/PDF for sharing
   - Use clear variable names and documentation
   - Include expected outputs in markdown

## Next Steps

This completes the big data Docker education series! You now have:

1. **Ubuntu + Java** - Foundation environment
2. **Hadoop Base** - HDFS and YARN fundamentals
3. **Hadoop Ingestion** - Data ingestion with Sqoop and Flume
4. **Hadoop Hive** - Data warehousing and SQL
5. **Hadoop Spark** - Advanced distributed processing
6. **Jupyter-Spark** - Interactive data science and analysis

The complete stack provides a comprehensive big data learning platform with:
- Distributed storage (HDFS)
- Resource management (YARN)
- Data ingestion tools
- SQL analytics (Hive)
- Distributed processing (Spark)
- Interactive development (Jupyter)

## Additional Resources

- **Jupyter Documentation**: https://jupyter.org/documentation
- **PySpark Guide**: https://spark.apache.org/docs/latest/api/python/
- **Spark MLlib**: https://spark.apache.org/docs/latest/ml-guide.html
- **Matplotlib Gallery**: https://matplotlib.org/stable/gallery/
- **Seaborn Tutorial**: https://seaborn.pydata.org/tutorial.html
- **Plotly Python**: https://plotly.com/python/

## Troubleshooting

**Issue: Jupyter won't start**
- Check if ports are already in use
- Verify Hadoop/Spark services are running
- Check container logs for errors

**Issue: Kernel dies when running Spark**
- Increase Docker memory allocation
- Reduce dataset size or use sampling
- Check Spark executor memory settings

**Issue: Visualizations don't render**
- Ensure `%matplotlib inline` is set
- Restart kernel and rerun cells
- Check if required libraries are installed

**Issue: Can't connect to HDFS**
- Verify HDFS is running: `hdfs dfs -ls /`
- Check namenode is accessible
- Ensure proper URI format: `hdfs://namenode:9000/path`

Happy big data learning with Jupyter and Spark!
