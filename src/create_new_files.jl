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
function tab2nc(infile, outfile, hdr, new_variables, var_units)
    # read .tab file
    d_tab = CSV.read(infile, DataFrame, skipto=hdr + 1, header=hdr, delim="\t")
    var_names = names(d_tab)

    # create output
    d_nc = NCDataset(outfile, "c")

    # define dimension
    defDim(d_nc, new_variables[1], Inf)

    # define the variables and assign their values
    for nv in eachindex(new_variables)
        nv_attr = Dict("long_name" => new_variables[nv], "units" => var_units[nv], "_FillValue" => -9999.0)
        display(nv_attr["long_name"])

        # define
        defVar(d_nc, new_variables[nv], Float64, (new_variables[1],), attrib=nv_attr)

        # assign
        display(d_tab[!, var_names[nv]])
        d_nc[new_variables[nv]][:] = d_tab[!, var_names[nv]]
    end

    close(d_nc)
end


(isfile("out.nc")) && (rm("out.nc"))
vars = ["Depth", "Age", "M. barleeanus MgCa", "BWT, bar L", "BWT, bar H", "M. affinis MgCa", "M. affinis MgCa corr", "BWT, af L", "BWT, af H"]
vars_units = ["m", "ka BP", "mmol/mol", "ºC", "ºC", "mmol/mol", "mmol/mol", "ºC", "ºC"]
path2data = "/home/sergio/entra/ice_data/Reconstructions/Repschlaeger-etal_2015/datasets/test_file.tab"
tab2nc(path2data, "out.nc", 22, vars, vars_units)