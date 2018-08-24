module DistributedEnv
using Distributed

include("abstractenv.jl")
include("actors/actors.jl")
include("distributedenv.jl")

function init_env(id::String, n::Int, workers=workers())
    @everywhere workers include(joinpath(@__DIR__, "actors", string(id2actor(name)) * ".jl")
    [[DistributedEnv(id, wid) for _ in 1:n] for wid in workers]
end

end # module
