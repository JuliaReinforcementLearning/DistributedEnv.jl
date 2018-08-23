module DistributedEnv
using Distributed

# include("abstractenv.jl")
include("gymenv.jl")

function init(workers=workers())
    @everywhere workers include(joinpath(@__DIR__, "actors", "gymactor.jl")
end

end # module
