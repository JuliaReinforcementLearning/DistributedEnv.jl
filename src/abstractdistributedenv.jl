using Distributed
using .Env
abstract type AbstractDistributedEnv <: AbstractEnv end

"send a message to an environment"
function send end

struct Message
    resbox::Distributed.AbstractRemoteRef
    method::String
    args::Tuple
    kw::Iterators.Pairs
end