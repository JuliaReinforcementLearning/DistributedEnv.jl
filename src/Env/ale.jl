using MLStyle
using ArcadeLearningEnvironment

struct AtariEnv <: AbstractEnv
    ale::Ptr{Nothing}
    screen::Array{UInt8, 1}
    getscreen::Function
    actions::Vector{Int32}
    noopmax::Int64
end

function AtariEnv(id::String;
                  colorspace = "Grayscale",
                  frame_skip = 4,
                  noopmax = 20,
                  color_averaging = true,
                  actionset = :minimal,
                  repeat_action_probability = 0.)
    ale = ALE_new()
    loadROM(ale, id)
    setBool(ale, "color_averaging", color_averaging)
    setInt(ale, "frame_skip", Int32(frame_skip))
    setFloat(ale, "repeat_action_probability", Float32(repeat_action_probability))
    actions = actionset == :minimal ? getMinimalActionSet(ale) : getLegalActionSet(ale)
    screen, get_screen = @match colorspace begin
        "Grayscale" => (Array{Cuchar}(undef, 210*160), getScreenGrayscale)
        "RGB"       => (Array{Cuchar}(undef, 3*210*160), getScreenRGB)
        "Raw"       => (Array{Cuchar}(undef, 210*160), getScreen)
        _           => throw("invalid colorspace $(env.colorspace)")
    end
    AtariEnv(ale, screen, get_screen, actions, noopmax)
end

function receive(env::AtariEnv, method::String, args::Tuple, kw::Iterators.Pairs)
    @match method begin
        "reset" => begin reset_game(env.ale)
                         for _ in 1:rand(0 : env.noopmax)
                            act(env.ale, Int32(0))
                         end
                         env.getscreen(env.ale, env.screen)
                         env.screen
                   end
        "step"  => begin reward = act(env.ale, env.actions[args...])
                         env.getscreen(env.ale, env.screen)
                         (env.screen, reward, game_over(env.ale))
                   end
        _       => nothing
    end
end


const atari_ids = [replace(x, r"\.bin$" => "")
    for x in readdir(joinpath(dirname(pathof(ArcadeLearningEnvironment)), "..", "deps", "roms"))]