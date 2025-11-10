# Jupyter Notebook with Spark Integration
# Builds on hadoop-spark image to provide interactive data analysis environment

FROM hadoop-spark:latest

LABEL maintainer="Big Data Education"
LABEL description="Jupyter Notebook with PySpark and Scala kernel for interactive big data analysis"

# Switch to root for installation
USER root

# Install Python dependencies for Jupyter and data science
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Jupyter with extensions
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir \
    jupyter \
    jupyterlab \
    notebook \
    ipykernel \
    ipywidgets

# Install PySpark and data science libraries
RUN pip3 install --no-cache-dir \
    pyspark==3.5.7 \
    py4j \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    plotly \
    scipy \
    scikit-learn \
    pyarrow \
    findspark \
    traitlets

# Install Toree (Scala kernel for Jupyter)
RUN pip3 install --no-cache-dir toree

# Install Toree kernel with Spark
RUN jupyter toree install \
    --spark_home=$SPARK_HOME \
    --interpreters=Scala,PySpark,SparkR,SQL \
    --user

# Create Jupyter configuration directory
RUN mkdir -p /home/hadoop/.jupyter

# Copy Jupyter configuration
COPY config/jupyter_notebook_config.py /home/hadoop/.jupyter/

# Create notebooks directory
RUN mkdir -p /home/hadoop/notebooks && \
    mkdir -p /home/hadoop/notebooks/examples && \
    mkdir -p /home/hadoop/notebooks/data

# Copy startup scripts
COPY scripts/*.sh /home/hadoop/scripts/
RUN chmod +x /home/hadoop/scripts/*.sh

# Copy exercises
COPY exercises/ /home/hadoop/exercises/

# Set ownership
RUN chown -R hadoop:hadoop /home/hadoop/.jupyter && \
    chown -R hadoop:hadoop /home/hadoop/notebooks && \
    chown -R hadoop:hadoop /home/hadoop/exercises

# Switch back to hadoop user
USER hadoop

# Set working directory
WORKDIR /home/hadoop/notebooks

# Expose Jupyter port
EXPOSE 8888

# Expose Spark UI port
EXPOSE 4040

# Set environment variables for PySpark to work with Jupyter
ENV PYSPARK_DRIVER_PYTHON=jupyter
ENV PYSPARK_DRIVER_PYTHON_OPTS='notebook'
ENV PYSPARK_PYTHON=python3

# Default command starts Jupyter Lab
CMD ["/home/hadoop/scripts/start-jupyter.sh"]
