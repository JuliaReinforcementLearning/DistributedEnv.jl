__precompile__(false)
module Env
export id2env, receive,
       reset!, interact!, getstate,
       GymEnv, AtariEnv, ViZDoomEnv, CartPole, MountainCar, Pendulum

include("Space/Space.jl")
include("abstractenv.jl")
include("pygymenv.jl")
include("ale.jl")
include("vizdoom.jl")
include("classic/classicenv.jl")

const supportedIDs = merge(Dict("pygym#" * x          => GymEnv for x in pygym_ids),
                           Dict("atari#" * x          => AtariEnv for x in atari_ids),
                           Dict("vizdoom#basic"       => ViZDoomEnv),
                           Dict("classic#cartpole"    => classicenv,
                                "classic#mountaincar" => classicenv,
                                "classic#pendulum"    => classicenv))

function id2env(id::String; kw...)
    haskey(supportedIDs, id) || throw("$id is not supported yet!")
    category, game_id = split(id, '#'; limit=2)
    supportedIDs[id](String(game_id);kw...)
end

function receive(env::AbstractEnv, method::String, args::Tuple, kw::Iterators.Pairs)
    @match method begin
        "reset"     => reset!(env)
        "interact"  => interact!(env, args[1])
        "getstate"  => getstate(env)
        _           => nothing
    end
end

end