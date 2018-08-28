using MLStyle
using PyCall
using .Space
@pyimport gym

const pygym_ids = [x[:id] for x in gym.envs[:registry][:all]()]

struct GymEnv <: AbstractEnv
    pyenv::PyObject
    state::PyObject
    observespace::AbstractSpace
    actspace::AbstractSpace
end

function GymEnv(id::String)
    pyenv = gym.make(id)
    GymEnv(pyenv,
           PyNULL(),
           gymspace2jlspace(pyenv[:observation_space]),
           gymspace2jlspace(pyenv[:action_space]))
end

function receive(env::GymEnv, method::String, args::Tuple, kw::Iterators.Pairs)
    @match method begin
        "reset" => (pycall!(env.state, env.pyenv[:reset], PyArray); env.state)
        "step"  => (pycall!(env.state, env.pyenv[:step], PyVector, args...);
                    (env.state[1], env.state[2], env.state[3]))
        _       => nothing
    end
end

function gymspace2jlspace(s::PyObject)
    @match s[:__class__][:__name__] begin
        "Box"           => BoxSpace(s[:low], s[:high])
        "Discrete"      => DiscreteSpace(s[:n])
        "MultiBinary"   => MultiBinarySpace(s[:n])
        "MultiDiscrete" => MultiDiscreteSpace(s[:nvec])
        "Tuple"         => map(gymspace2jlspace, s[:spaces])
        "Dict"          => Dict(map((k, v) -> (k, gymspace2jlspace(v)), s[:spaces]))
    end
end