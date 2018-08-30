using MLStyle
using PyCall
using .Space
@pyimport gym

const pygym_ids = [x[:id] for x in gym.envs[:registry][:all]()]

struct GymEnv <: AbstractEnv
    pyenv::PyObject
    state::PyObject
    observespace::AbstractSpace
    actionspace::AbstractSpace
end

function GymEnv(id::String)
    pyenv = gym.make(id)
    GymEnv(pyenv,
           PyNULL(),
           gymspace2jlspace(pyenv[:observation_space]),
           gymspace2jlspace(pyenv[:action_space]))
end

function reset!(env::GymEnv)
    pycall!(env.state, env.pyenv[:reset], PyArray)
    env.state
end

function interact!(env::GymEnv, a)
    pycall!(env.state, env.pyenv[:step], PyVector, a)
    (observe=env.state[1], reward=env.state[2], isdone=env.state[3])
end

getstate(env::GymEnv) = (observe=env.state[1], isdone=env.state[3])

function gymspace2jlspace(s::PyObject)
    @match s[:__class__][:__name__] begin
        "Box"           => BoxSpace(s[:low], s[:high])
        "Discrete"      => DiscreteSpace(s[:n], 0)
        "MultiBinary"   => MultiBinarySpace(s[:n])
        "MultiDiscrete" => MultiDiscreteSpace(s[:nvec], 0)
        "Tuple"         => map(gymspace2jlspace, s[:spaces])
        "Dict"          => Dict(map((k, v) -> (k, gymspace2jlspace(v)), s[:spaces]))
        x               => throw("Unsupported space type $(x)")
    end
end