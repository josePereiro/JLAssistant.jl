## ---------------------------------------------------------
# CLI
function run_open_devpath_workspace(argv=ARGS)

    ## ---------------------------------------------------------
    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "name"
            help = "The workspace name"
            arg_type = String
        "-d"
            help = "Dry run"
            action = :store_true
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    name = parsed_args["name"]
    dryrun = parsed_args["d"]

    ## ---------------------------------------------------------
    _print_options(;name, dryrun) 
    
    ## ---------------------------------------------------------
    path = _find_dev_workspace(name)
    isempty(path) && error("Workspace not found, name = $(name)")

    println(); @info("Opening workspace", path)
    !dryrun && run(`code $path`)

    return nothing

end
