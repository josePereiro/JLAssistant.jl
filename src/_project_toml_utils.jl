## ---------------------------------------------------
function _key_by(key)
    _toml_order = ["name", "uuid", "authors", "version", "deps", "compat", "extras", "targets"]
    idx = findfirst(isequal(key), _toml_order)
    isnothing(idx) ? 9223372036854775807 : idx
end

function _save_project(projfile, projdict) 
    open(projfile, "w") do io
        TOML.print(io, projdict; sorted=true, by=_key_by)
    end
end

_load_project(projfile) = TOML.parsefile(projfile)