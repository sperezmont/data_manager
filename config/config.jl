
"""
Aim: This script configures the virtual environment for using data_manager\n
Author: Sergio Pérez Montero\n
Date: 2023.01.02\n
"""

# Check if environment exists
env_name = "data_manager_env"
if isdir(env_name) # check if exists
    rm(env_name, recursive=true)
end

# Environment generation
using Pkg
Pkg.generate(env_name)
Pkg.activate(env_name)

# Adding dependencies ... 
display("** Adding dependencies ... **")
packages = ["NCDatasets", "CSV", "DataFrames", "CairoMakie", "DSP", "Statistics", "Wavelets", "ContinuousWavelets", "Interpolations"]
for i in packages
    Pkg.add(i)
end

# Check status
Pkg.precompile()
Pkg.instantiate()
display("**** data_manager ready ****")

