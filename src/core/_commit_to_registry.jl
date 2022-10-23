function _commit_to_registry(pkg::String; 
        registry::String = "", verbose = false, push = true
    )

    # parse args
    pkg = isempty(pkg) ? basename(pwd()) : pkg

    # add to registry
    verbose && _info("Update registry"; pkg, registry, push)
    isempty(registry) ?
        LocalRegistry.register(pkg; push) :
        LocalRegistry.register(pkg; registry, push)

    return pkg
end