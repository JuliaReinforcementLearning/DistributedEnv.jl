module DistributedEnv
export init_env

include("Env/Env.jl")
include("abstractenv.jl")
include("denv.jl")

function init_env(id::String, n::Int=1, workers::Vector{Int}=workers())
    [DEnv(id, wid) for wid in workers for _ in 1:n]
end

end # module
