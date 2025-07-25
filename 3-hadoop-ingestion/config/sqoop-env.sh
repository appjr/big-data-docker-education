#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set Hadoop-specific environment variables here.

# Set Hadoop configuration directory
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Set path to where bin/hadoop is available
export HADOOP_COMMON_HOME=$HADOOP_HOME

# Set path to where hadoop-*-core.jar is available
export HADOOP_MAPRED_HOME=$HADOOP_HOME

# Set the path to where bin/hbase is available
#export HBASE_HOME=

# Set the path to where bin/hive is available
#export HIVE_HOME=

# Set the path for where zookeper config dir is
#export ZOOCFGDIR=
