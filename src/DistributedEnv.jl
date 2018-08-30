module DistributedEnv
export init_env, interact!, reset!, getstate, actionspace

using Reexport
include("Env/Env.jl")
import .Env: interact!, reset!, getstate, actionspace
include("abstractdistributedenv.jl")
include("denv.jl")

function init_env(id::String; n::Int=1, workers::Vector{Int}=workers())
    [DEnv(id, wid) for wid in workers for _ in 1:n]
end

interact!(denv::DEnv, args...) = send(denv, "interact", args...)
reset!(denv::DEnv) = send(denv, "reset")
getstate(denv::DEnv) = send(denv, "getstate")
actionspace(denv::DEnv) = denv.actionspace

end # module
