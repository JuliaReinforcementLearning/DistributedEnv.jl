using MLStyle
using PyCall
@pyimport gym

struct GymEnv <: AbstractEnv
    pyenv::PyObject
    state::PyObject
end

function GymEnv(id::String)
    GymEnv(gym.make(id), PyNULL())
end

function receive(env::GymEnv, method::String, args::Tuple, kw::Iterators.Pairs)
    @match method begin
        "reset" => (pycall!(env.state, env.pyenv[:reset], PyArray); env.state)
        "step"  => (pycall!(env.state, env.pyenv[:step], PyVector, args...);
                    (env.state[1], env.state[2], env.state[3]))
        _       => nothing
    end
end

const pygym_ids = [x[:id] for x in gym.envs[:registry][:all]()]