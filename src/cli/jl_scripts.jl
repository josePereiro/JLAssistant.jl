## ---------------------------------------------------------
# CLI
function run_jl_script(argv=ARGS)

    ## ---------------------------------------------------------
    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "name"
            help = "The script name"
            arg_type = String
    end

    argv = length(argv) > 1 ? argv[1:1] : argv
    parsed_args = ArgParse.parse_args(argv, argset)
    name = parsed_args["name"]

    ## ---------------------------------------------------------
    _print_options(;name) 
    
    ## ---------------------------------------------------------
    _run_jl_script(name)

end