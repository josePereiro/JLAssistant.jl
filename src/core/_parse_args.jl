
const SHORT_FLAG_REGEX = r"^-(?<flag>\w)$"
const SHORT_FLAG_VALUE_REGEX = r"^-(?<flag>\w)=(?<value>\S+)$"
const SHORT_FLAG_VALUE_REGEX2 = r"^-(?<flag>\w)(?<value>\S+)$"
const LONG_FLAG_REGEX = r"^--(?<flag>\w+)$"
const LONG_FLAG_VALUE_REGEX = r"^--(?<flag>\w+)=(?<value>\S+)$"
const OPT_VALUE_REGEX = r"^(?<value>[^-]\N*)$"

# --------------------------------------------------------
function foreach_args(argsv::Vector; 
        onarg = (x...) -> nothing, 
        onopt = (x...) -> nothing, 
        onfinish = (x...) -> nothing,
        onerr = (x...) -> nothing
    )

    opt_num = 0
    for arg in argsv

        m = nothing
        
        # OPTION
        m = match(OPT_VALUE_REGEX, arg)
        if !isnothing(m) 
            opt_num += 1
            ret = onarg(opt_num, string(m[:value]))
            ret === true && return
        end
        !isnothing(m) && continue

        # FLAGS
        for reg in [
                SHORT_FLAG_VALUE_REGEX, SHORT_FLAG_VALUE_REGEX2, 
                LONG_FLAG_VALUE_REGEX, 
                SHORT_FLAG_REGEX, LONG_FLAG_REGEX
            ] # Order matter
            
            m = match(reg, arg)
            
            isnothing(m) && continue
            flag = string(m[:flag])
            value = haskey(m, :value) ? string(m[:value]) : ""
            ret = onopt(flag, value)
            ret === true && return
            break
        end
        !isnothing(m) && continue

        onerr(arg)
    end

    onfinish()

end

function parse_args(argsv::Vector; 
        onfinish = (x...) -> nothing,
        onerr = (x...) -> nothing
    )
    
    args = String[]
    opts = Dict{String, String}()

    onarg = (n, v) -> push!(args, v)
    onopt = (f, v) -> opts[f] = v

    foreach_args(argsv; onarg, onopt, onfinish, onerr)

    return (args, opts)
end