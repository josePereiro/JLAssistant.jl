# _is_unregistered(dat::Dict) = haskey(dat, "repo-rev") || haskey(dat, "repo-url") || haskey(dat, "path")
_is_unregistered(pkginfo::Pkg.API.PackageInfo) = !pkginfo.is_tracking_registry

function _find_unregistered_pkgs(pkgdir)
    devs = String[]
    Pkg.activate(pkgdir) do
        for (_, pkginfo) in Pkg.dependencies()
            _is_unregistered(pkginfo) && push!(devs, pkginfo.name)
        end
    end
    return devs
end