"""
    Aim: This script aims to create lisiecki-raymo_2005_LR04stack.nc from txt data      \n
    Author: Sergio Pérez Montero (github.com/sperezmont)                                \n
    Date: 2023.01.10                                                                    \n
"""

using Pkg
Pkg.activate("data_manager_env")                    # -- activate virtual environment
using NCDatasets        # to make outputs and manage inputs (?)
using CSV, DataFrames

# Variables
in_file = "/home/sergio/entra/ice_data/Reconstructions/Spratt-Lisiecki_2016/spratt2016.txt"
out_file = "/home/sergio/entra/ice_data/Reconstructions/Spratt-Lisiecki_2016/spratt-lisiecki_2016.nc"
long_names = ["age_calka", "SeaLev_shortPC1", "SeaLev_shortPC1_err_sig", "SeaLev_shortPC1_err_lo", "SeaLev_shortPC1_err_up",
        	  "SeaLev_longPC1",	"SeaLev_longPC1_err_sig", "SeaLev_longPC1_err_lo", "SeaLev_longPC1_err_up"]
units = ["ka", "m SLE", "m SLE", "m SLE", "m SLE", "m SLE", "m SLE", "m SLE", "m SLE"]
factor2multiply = [-1, 1, 1, 1, 1, 1, 1, 1, 1]
metadata_text = ""

# Read original file
d = CSV.read(in_file, DataFrame, delim="\t", header=96)
d = d[!, 1:9]
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
