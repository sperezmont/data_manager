"""
    Aim: This script aims to create luthi-etal_2008.nc from txt data      \n
    Author: Sergio Pérez Montero (github.com/sperezmont)                                \n
    Date: 2023.01.12                                                                    \n
"""

using Pkg
Pkg.activate("data_manager_env")                    # -- activate virtual environment
using NCDatasets        # to make outputs and manage inputs (?)
using CSV, DataFrames

# Variables
in_file = "/home/sergio/entra/ice_data/Reconstructions/Luthi-etal_2008/luthi-etal_2008.txt"
out_file = "/home/sergio/entra/ice_data/Reconstructions/Luthi-etal_2008/luthi-etal_2008.nc"
long_names = ["EDC3_gas_a (kyr)", "CO2 (ppmv)"]
units = ["ka", "ppmv"]
factor2multiply = [-1/1000, 1]
metadata_text = ""

# Read original file
d = CSV.read(in_file, DataFrame, delim="\t", header=1)
d = d[!, 1:end]
d_names = names(d)

# Create netCDF
isdir(out_file) && rm(out_file)
dnc = NCDataset(out_file, "c")

# -- define time dimension
defDim(dnc, d_names[1], length(d[!, d_names[1]]))

# -- define nc variables and assign their values
for v in eachindex(d_names)
    v_attr = Dict("long_name" => long_names[v], "units" => units[v], "_FillValue" => -9999.0)

    # ---- define
    defVar(dnc, d_names[v], Float64, (d_names[1],), attrib=v_attr)

    # ---- assign
    values = factor2multiply[v] .* reverse(d[!, d_names[v]])
    dnc[d_names[v]][:] = values

end
# Close netCDF
close(dnc)
