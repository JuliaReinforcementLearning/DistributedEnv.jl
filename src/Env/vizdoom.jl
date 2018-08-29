using .Space
using ViZDoom
const vz = ViZDoom

struct ViZDoomEnv <: AbstractEnv
    game::vz.DoomGameAllocated
    actions::Vector{Vector{Float64}}
    actionspace::DiscreteSpace
end

function ViZDoomEnv(::String; add_game_args = "", kw...)
    defaults = (screen_format = :GRAY8, screen_resolution = :RES_160X120, 
                window_visible = false, living_reward = 0, 
                episode_timeout = 500)
    config = Dict(pairs(merge(defaults, kw)))
    for (k, v) in config
        if typeof(v) == Symbol
            config[k] = getfield(vz, v)
        elseif typeof(v) <: AbstractArray && typeof(v[1]) == Symbol
            config[k] = map(x -> getfield(vz, x), v)
        end
    end
    game = vz.basic_game(; config...)
    vz.add_game_args(game, add_game_args)
    na = haskey(config, :available_buttons) ? length(config[:available_buttons]) : 3
    actions = [Float64[i == j for i in 1:na] for j in 1:na]
    env = ViZDoomEnv(game, 
                     actions,
                     DiscreteSpace(length(actions), 1))
    init!(env)
    env
end

reset!(env::ViZDoomEnv) = (vz.new_episode(env.game); vz.get_screen_buffer(env.game))
getstate(env::ViZDoomEnv) = (observe=vz.get_screen_buffer(env.game), isdone=vz.is_episode_finished(env.game))

function interact!(env::ViZDoomEnv, a)
    reward=vz.make_action(env.game, env.actions[a])
    (observe=vz.get_screen_buffer(env.game), reward=reward, isdone=vz.is_episode_finished(env.game))
end