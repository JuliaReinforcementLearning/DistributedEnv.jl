__precompile__(false)
module Env
export id2env

include("pygymenv.jl")

const supportedIDs = Dict(x => pygymenv for x in pygymids())

function id2env(id::String)
    haskey(supportedIDs, id) || throw("$id is not supported yet!")
    supportedIDs[id](id)
end

end