## ---------------------------------------------------------
# CLI
function run_upgrade_manifests(argv=ARGS)

    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "rootdir"
            help="Root directory"
            arg_type = String
            default = pwd()
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    rootdir = parsed_args["rootdir"]

    _walk_pkgs(;rootdir) do path, proj
        Pkg.activate(path)
        println()
        try
            @info("Upgrading")
            Pkg.upgrade_manifest()
        catch err
            (err isa InterruptException) && rethrow(err)
            @error("Update Fails", err)
        end
        println()
    end
end