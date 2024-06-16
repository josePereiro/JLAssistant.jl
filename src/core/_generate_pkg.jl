_load_gitignore() = read(joinpath(pkgdir(JLAssistant), ".gitignore"), String)
_default_user() = LibGit2.getconfig("user.name", "")

function _load_template(tmp, replaces::Dict)
    txt = read(joinpath(pkgdir(JLAssistant), "templates", tmp), String)
    for (key, val) in replaces
        txt = replace(txt, string("{{", key, "}}") => val)
    end
    return txt
end

_default_plugins() = [
    # allowed
    PkgTemplates.Git(ignore = [_load_gitignore()], manifest = false, branch = "main"),
    PkgTemplates.ProjectFile(), 
    PkgTemplates.SrcDir(),
    PkgTemplates.Tests(), 
    PkgTemplates.License(), 
    PkgTemplates.Codecov(),
    PkgTemplates.GitHubActions(;coverage = true),
    
    # disallowed
    !PkgTemplates.Readme, 
    !PkgTemplates.CompatHelper, 
    !PkgTemplates.TagBot
]

function _generate(pkgname; 
        julia = v"1.10.0",
        github_user = ""
    )

    # Args
    pkgname = replace(pkgname, ".jl" => "")
    github_user = isempty(github_user) ? _default_user() : github_user

    dir = Pkg.devdir()
    _pkgdir = joinpath(dir, pkgname)
    
    # REST
    # TODO: Stop using PkgTemplates, use templates better
    plugins = _default_plugins()
    t = PkgTemplates.Template(;user = github_user, julia, plugins, dir)
    PkgTemplates.generate(t, pkgname)

    # TEMPLATES
    # copy tagged-release.yml
    # TODO: make it work again
    # _cp(
    #     joinpath(pkgdir(JLAssistant), ".github/workflows/tagged-release.yml"),
    #     joinpath(_pkgdir, ".github/workflows/tagged-release.yml");
    #     force = true
    # )

    # ci
    _cp(
        joinpath(pkgdir(JLAssistant), "templates/CI.yml"),
        joinpath(_pkgdir, ".github/workflows/CI.yml");
        force = true
    )

    # README
    # TODO: make cli
    readme_txt = _load_template("README.md", Dict(
        "NAME" => pkgname,
        "GITHUB-URL" => "https://github.com/$(github_user)/$(pkgname).jl",
        "CODECOV-URL" => "https://codecov.io/gh/$(github_user)/$(pkgname).jl"
    ))
    readme_file = joinpath(_pkgdir, "README.md")
    rm(readme_file; force = true)
    open(readme_file, "w") do io
        print(io, readme_txt)
    end
    
    return _pkgdir
end
