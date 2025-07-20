FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Install essential packages and Java 11
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    curl \
    vim \
    nano \
    ssh \
    rsync \
    net-tools \
    sudo \
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create hadoop user with sudo privileges
RUN useradd -m -s /bin/bash hadoop && \
    echo "hadoop:hadoop" | chpasswd && \
    usermod -aG sudo hadoop && \
    echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up SSH for hadoop user
USER hadoop
WORKDIR /home/hadoop

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

# Copy scripts and exercises
COPY --chown=hadoop:hadoop scripts/ /home/hadoop/scripts/
COPY --chown=hadoop:hadoop exercises/ /home/hadoop/exercises/

# Make scripts executable
RUN chmod +x /home/hadoop/scripts/*.sh

# Expose SSH port
EXPOSE 22

# Start SSH service and keep container running
CMD ["sudo", "service", "ssh", "start", "&&", "tail", "-f", "/dev/null"]
