using ViZDoom
const vz = ViZDoom

struct ViZDoomEnv <: AbstractEnv
    game::vz.DoomGameAllocated
    actions::Vector{Vector{Float64}}
    sleeptime::Float64
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
    if config[:window_visible]
        sleeptime = 1.0 / vz.DEFAULT_TICRATE
    else
        sleeptime = 0.
    end
    na = haskey(config, :available_buttons) ? length(config[:available_buttons]) : 3
    env = ViZDoomEnv(game, 
                     [Float64[i == j for i in 1:na] for j in 1:na],
                     sleeptime)
    init!(env)
    env
end


function receive(env::ViZDoomEnv, method::String, args::Tuple, kw::Iterators.Pairs)
    @match method begin
    end
end