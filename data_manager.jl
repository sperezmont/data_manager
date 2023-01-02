# =============================
#     Program: data_manager.jl
#     Aim: prepare Julia for using data_manager
#     Author: Sergio Pérez Montero
#     Date: 2023.01.02
# =============================
println("Getting Julia ready to use data_manager ...")
using Pkg
Pkg.activate("data_manager_env")                    # -- activate virtual environment

# -- import dependencies
using NCDatasets        # to make outputs and manage inputs (?)
using CSV, DataFrames

# -- import functions
include("src/create_new_files.jl")

println("Done!")





