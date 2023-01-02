"""
    Aim: This script contains functions to create new data files from existing inputs   \n
    Author: Sergio Pérez Montero (github.com/sperezmont)                                \n
    Date: 2023.01.02                                                                    \n
"""

@doc """
    tab2nc: creates 1D .nc file from .tab 1D file   \n
        infile      --> input file path * input name    \n
        outputfile  --> output file path * output name  \n
        hdr         --> number with the location of header  \n
"""
function tab2nc(infile::String, outfile::String, hdr::Int, new_variables::Vector, var_attributes::Dict)
    # read .tab file
    d_tab = CSV.read(infile, DataFrame, skipto=hdr + 1, header=hdr, delim="\t", missingstring="NULL")
    var_names = names(d_tab)

    # create outputs
    d_nc = NCDataset(outfile, "c")

    # define dimension
    defDim(d_nc, var_names[1], Inf)

    # define the variables
    for nv in new_variables
        defVar(d_nc, nv, Float64, (nv[1],), attrib=var_attributes[nv])
    end

    return d_tab
end

include("data_manager.jl")
vars = ["Depth", "Age", "M. barleeanus Mg/Ca", "BWT, L", "BWT, H", "M. affinis Mg/Ca", "M. affinis Mg/Ca corr", "BWT, L", "BWT, H"]
vars_units = ["m", "ka BP", "mmol/mol", "ºC", "ºC", "mmol/mol", "mmol/mol", "ºC", "ºC"]
vars_attr = Dict(vars .=> vars_units)
tab2nc(path2data, "out.nc", 22, vars, vars_attr)