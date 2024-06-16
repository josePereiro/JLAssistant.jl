_load_gitignore() = read(joinpath(pkgdir(JLAssistant), ".gitignore"), String)
_default_user() = LibGit2.getconfig("user.name", "")

_default_plugins() = [
    # allowed
    PkgTemplates.Git(ignore = [_load_gitignore()], manifest = false, branch = "main"),
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

function _generate(pkgname; 
        user = _default_user(), julia = v"1.10.0"
    )

    pkgname = replace(pkgname, ".jl" => "")

    dir = Pkg.devdir()
    _pkgdir = joinpath(dir, pkgname)

    plugins = _default_plugins()
    t = PkgTemplates.Template(;user, julia, plugins, dir)
    PkgTemplates.generate(t, pkgname)

    # copy tagged-release.yml
    # TODO: make it work again
    # _cp(
    #     joinpath(pkgdir(JLAssistant), ".github/workflows/tagged-release.yml"),
    #     joinpath(_pkgdir, ".github/workflows/tagged-release.yml");
    #     force = true
    # )

    # ci
    _cp(
        joinpath(pkgdir(JLAssistant), ".github/workflows/CI.yml"),
        joinpath(_pkgdir, ".github/workflows/CI.yml");
        force = true
    )
    
    return _pkgdir
end
