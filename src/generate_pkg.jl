const _SELF_ROOT = dirname(@__DIR__)

_load_gitignore() = read(joinpath(_SELF_ROOT, ".gitignore"), String)
_default_user() = LibGit2.getconfig("user.name", "")

_default_plugins() = [
    # allowed
    PkgTemplates.Git(ignore = [_load_gitignore()], manifest = true, branch = "main"),
    PkgTemplates.ProjectFile(), 
    PkgTemplates.SrcDir(),
    PkgTemplates.Tests(), 
    PkgTemplates.Readme(), 
    PkgTemplates.License(), 
    PkgTemplates.Codecov(),
    PkgTemplates.GitHubActions(;coverage = true),

    # disallowed
    !PkgTemplates.CompatHelper, 
    !PkgTemplates.TagBot
]

function _cp(src_, dst_; kwargs...)
    mkpath(dirname(src_))
    mkpath(dirname(dst_))
    cp(src_, dst_; kwargs...)
end

function _generate(pkgname; 
        user = _default_user(), julia = v"1.6.0"
    )

    dir = Pkg.devdir()
    pkgdir = joinpath(dir, replace(pkgname, ".jl" => ""))

    plugins = _default_plugins()
    t = PkgTemplates.Template(;user, julia, plugins, dir)
    PkgTemplates.generate(t, pkgname)

    # copy tagged-release.yml
    _cp(
        joinpath(_SELF_ROOT, ".github/workflows/tagged-release.yml"),
        joinpath(pkgdir, ".github/workflows/tagged-release.yml");
        force = true
    )
    
    return pkgdir
end

function run_generate_pkg(argv=ARGS)

    argset = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! argset begin
        "pkgname"
            help="The package name"
            required = true    
        "--code", "-c"
            help = "Will open the project after creation"
            action = :store_true
    end

    parsed_args = ArgParse.parse_args(argv, argset)
    pkgname = parsed_args["pkgname"]
    code = parsed_args["code"]

    ## ---------------------------------------------------------
    pkgdir = _generate(pkgname)
    
    ## ---------------------------------------------------------
    if code
        run(Cmd(["code", pkgdir]); wait=true)
    end

end