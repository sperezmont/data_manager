"""
    Aim: This script aims to create snyder_2016.nc from txt data      \n
    Author: Sergio Pérez Montero (github.com/sperezmont)                                \n
    Date: 2023.01.12                                                                    \n
"""

using Pkg
Pkg.activate("data_manager_env")                    # -- activate virtual environment
using NCDatasets        # to make outputs and manage inputs (?)
using CSV, DataFrames

# Variables
in_file = "/home/sergio/entra/ice_data/Reconstructions/Snyder_2016/snyder_2016.txt"
out_file = "/home/sergio/entra/ice_data/Reconstructions/Snyder_2016/snyder_2016.nc"
long_names = ["Time (kyr)", "Change in Global Average Surface Temperature (GAST) from present (0-5ka average), 2.5%",
              "Change in Global Average Surface Temperature (GAST) from present (0-5ka average), 5%",
              "Change in Global Average Surface Temperature (GAST) from present (0-5ka average), 25%",
              "Change in Global Average Surface Temperature (GAST) from present (0-5ka average), 50%",
              "Change in Global Average Surface Temperature (GAST) from present (0-5ka average), 75%",
              "Change in Global Average Surface Temperature (GAST) from present (0-5ka average), 95%",
              "Change in Global Average Surface Temperature (GAST) from present (0-5ka average), 97.5%"]
units = ["kyr", "K", "K", "K", "K", "K", "K", "K"]
factor2multiply = [-1, 1, 1, 1, 1, 1, 1, 1]
metadata_text = ""

# Read original file
d = CSV.read(in_file, DataFrame, delim="\t", header=1)
d = d[!, 1:end]
d_names = ["Time", "GAST(2.5%)", "GAST(5%)", "GAST(25%)", "GAST(50%)",	"GAST(75%)", "GAST(95%)", "GAST(97.5%)"] #names(d)

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
