include("gymactor.jl")

function id2actor(name::String)
    Dict(x => gymactor for x in gymids())
end