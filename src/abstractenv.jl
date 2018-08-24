using Distributed
abstract type AbstractEnv end

"send a message to an environment"
function send end

struct Message
    resbox::Future
    method::Symbol
    args::Tuple
end