function run_update_manifests(argv=ARGS)

    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "rootdir"
            help="Root directory"
            arg_type = String
            default = pwd()
        "--precompile", "-p"
            help = "Precompile the projects after update"
            action = :store_true
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    rootdir = parsed_args["rootdir"]
    precompile = parsed_args["precompile"]

    _walk_pkgs(;rootdir) do path, proj
        try;
            Pkg.activate(path) 
            Pkg.update()
            precompile && Pkg.precompile()
            catch err; @error("Update Fails", err)
        end
    end
end