using Distributed
abstract type AbstractDistributedEnv end

"send a message to an environment"
function send end

struct Message
    resbox::Distributed.AbstractRemoteRef
    method::String
    args::Tuple
    kw::Iterators.Pairs
end