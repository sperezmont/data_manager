"""
    Aim: This script aims to create waelbroeck-etal_2002.nc from txt data               \n
    Author: Sergio Pérez Montero (github.com/sperezmont)                                \n
    Date: 2023.01.10                                                                    \n
"""

using Pkg
Pkg.activate("data_manager_env")                    # -- activate virtual environment
using NCDatasets        # to make outputs and manage inputs (?)
using CSV, DataFrames

# Variables
in_file = "/home/sergio/entra/ice_data/Reconstructions/Waelbroeck-etal_2002/waelbroeck-etal_2002_raw-data.txt"
out_file = "/home/sergio/entra/ice_data/Reconstructions/Waelbroeck-etal_2002/waelbroeck-etal_2002.nc"
long_names = ["Calendar age, cal. ky", "Mean ocean d18O, per mil SMOW", "Minimum mean ocean d18O, per mil SMOW", "Maximum mean ocean d18O, per mil SMOW",
               "Global mean sea level, m below present sea level", "Minimum global mean sea level, m below present sea level", "Maximum global mean sea level, m below present sea level",
               "Alternate age model, 14C + SPECMAP, no Termination II Adjustment", "Alternate age model, adjusted to Martinson et al. (1987) time scale, prior to 33 ky BP only", "Alternate age model, adjusted to Martinson et al. (1987) time scale all the way"
               ]
units = ["ka", "o/oo", "o/oo", "o/oo", "m", "m", "m", "ka", "ka", "ka"]
factor2multiply = [-1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
metadata_text = ""

# Read original file
d = CSV.read(in_file, DataFrame, delim="\t")
d_names = names(d)

# Create netCDF
isdir(out_file) && rm(out_file)
dnc = NCDataset(out_file, "c")

# -- define time dimension
defDim(dnc, d_names[1], length(d[!, d_names[1]]))

# -- define nc variables and assign their values
for v in eachindex(d_names)
    v_attr = Dict("long_name" => long_names[v], "units" => units[v], "scale_factor" => factor2multiply[v], "_FillValue" => -9999.0)

    # ---- define
    defVar(dnc, d_names[v], Float64, (d_names[1],), attrib=v_attr)

    # ---- assign
    values = factor2multiply[v] .* reverse(d[!, d_names[v]])
    dnc[d_names[v]][:] = values

end
# Close netCDF
close(dnc)
