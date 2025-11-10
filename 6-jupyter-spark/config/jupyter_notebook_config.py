# Jupyter Notebook Configuration File
# Configuration for Jupyter Notebook server with Spark integration

import os
from traitlets.config import get_config  # type: ignore

# Configuration object - use get_config() to properly initialize
c = get_config()

# Network configuration
c.NotebookApp.ip = '0.0.0.0'  # Allow connections from any IP
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.allow_origin = '*'
c.NotebookApp.allow_remote_access = True

# Security settings
c.NotebookApp.token = ''  # No token required (for educational purposes only)
c.NotebookApp.password = ''  # No password required (for educational purposes only)
# For production, set a password using: jupyter notebook password

# Directory configuration
c.NotebookApp.notebook_dir = '/home/hadoop/notebooks'

# Enable extensions
c.NotebookApp.nbserver_extensions = {
    'jupyter_nbextensions_configurator': True,
}

# Terminal configuration
c.NotebookApp.terminals_enabled = True

# Kernel configuration
c.NotebookApp.kernel_spec_manager_class = 'jupyter_client.kernelspec.KernelSpecManager'

# Logging
c.NotebookApp.log_level = 'INFO'

# Max buffer size for messages (useful for large dataframes)
c.NotebookApp.iopub_data_rate_limit = 10000000
c.NotebookApp.iopub_msg_rate_limit = 10000

# Spark configuration (passed to PySpark)
c.NotebookApp.tornado_settings = {
    'headers': {
        'Content-Security-Policy': "frame-ancestors 'self' *"
    }
}

# Session configuration
c.NotebookApp.shutdown_no_activity_timeout = 0  # Don't auto-shutdown
c.MappingKernelManager.cull_idle_timeout = 0  # Don't cull idle kernels
c.MappingKernelManager.cull_interval = 0
