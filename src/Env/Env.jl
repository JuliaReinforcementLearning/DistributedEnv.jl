__precompile__(false)
@reexport module Env
export id2env, receive,
       reset!, interact!, getstate, actionspace,
       AbstractEnv, GymEnv, AtariEnv, ViZDoomEnv, CartPole, MountainCar, Pendulum

using Reexport
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
        "reset"       => reset!(env)
        "interact"    => interact!(env, args[1])
        "getstate"    => getstate(env)
        "actionspace" => env.actionspace
        _             => nothing
    end
end

actionspace(env::AbstractEnv) = env.actionspace

end