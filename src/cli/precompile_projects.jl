function run_precompile_projects(argv=ARGS)

    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "rootdir"
            help="Root directory"
            arg_type = String
            default = pwd()
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    rootdir = parsed_args["rootdir"]
    
    ## ---------------------------------------------------------
    _print_options(;rootdir)

    _walk_pkgs(;rootdir) do path, proj
        try;
                Pkg.activate(path) 
                Pkg.precompile()
            catch err; @error("Precompilation Fails", err)
        end
    end
end