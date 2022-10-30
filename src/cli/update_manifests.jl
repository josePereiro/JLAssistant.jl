## ---------------------------------------------------------
# CLI
function run_update_manifests(argv=ARGS)

    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "rootdir"
            help="Root directory"
            arg_type = String
            default = pwd()
        "--precompile", "-c"
            help = "Precompile the projects after update"
            action = :store_true
        "--pkgs", "-p"
            help = "Specific packages to update"
            arg_type = String
            default = ""
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    rootdir = parsed_args["rootdir"]
    precompile = parsed_args["precompile"]
    packages = _split_arglist(parsed_args["pkgs"])

    ## ---------------------------------------------------------
    _print_options(;rootdir, precompile, packages)

    _walk_pkgs(;rootdir) do path, proj
        Pkg.activate(path)
        println()
        if isempty(packages)
            try;
                @info("Updating All")
                Pkg.update()
            catch err
                (err isa InterruptException) && rethrow(err)
                @error("Update Fails", err)
            end
        else
            for name in packages
                isempty(name) && continue
                try;
                    @info("Updating", name)
                    spec = PackageSpec(;name)
                    Pkg.update(spec; level=Pkg.UPLEVEL_MAJOR, mode=Pkg.PKGMODE_MANIFEST)
                catch err
                    (err isa InterruptException) && rethrow(err)
                    @error("Update Fails", err)
                end
            end
        end

        precompile && Pkg.precompile()
    end
end