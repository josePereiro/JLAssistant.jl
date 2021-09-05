function run_import_pkgs(argv=ARGS)

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

        ispackage = haskey(proj, "name")
        if ispackage
            name = proj["name"]
            try;
                cmd = _Cmd(["julia", "--startup-file=no", "--project=$(path)", "-e", 
                    "import $(name); println(\"$(name)\", \" imported\")"])
                run(cmd; wait = true)
            catch err; 
                @error("Failing importing ", name, err)
            end
        else
        end
    end
end