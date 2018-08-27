__precompile__(false)
module Env
export id2env, receive

include("abstractenv.jl")
include("pygymenv.jl")

const supportedIDs = Dict(x => GymEnv for x in pygymids())

function id2env(id::String; kw...)
    haskey(supportedIDs, id) || throw("$id is not supported yet!")
    supportedIDs[id](id;kw...)
end

end