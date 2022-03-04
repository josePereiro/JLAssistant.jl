_load_gitignore() = read(joinpath(pkgdir(JLAssistant), ".gitignore"), String)
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
        joinpath(pkgdir(JLAssistant), ".github/workflows/tagged-release.yml"),
        joinpath(pkgdir, ".github/workflows/tagged-release.yml");
        force = true
    )
    
    return pkgdir
end
