using .Space

struct MountainCarParams{T}
    minpos::T
    maxpos::T
    maxspeed::T
    goalpos::T
    maxsteps::Int64
end

mutable struct MountainCar{T} <: AbstractEnv
    params::MountainCarParams{T}
    actionspace::DiscreteSpace
    state::Array{T, 1}
    done::Bool
    t::Int64
end

function MountainCar(; T = Float64, minpos = T(-1.2), maxpos = T(.6),
                       maxspeed = T(.07), goalpos = T(.5), maxsteps = 200)
    env = MountainCar(MountainCarParams(minpos, maxpos, maxspeed, goalpos, maxsteps),
                      DiscreteSpace(3, 1),
                      zeros(T, 2),
                      false, 0)
    reset!(env)
    env
end

function getstate(env::MountainCar)
    (observe=env.state, isdone=env.done)
end

function reset!(env::MountainCar{T}) where T
    env.state[1] = .2 * rand(T) - .6
    env.state[2] = 0.
    env.done = false
    env.t = 0
    env.state
end

function interact!(env::MountainCar, a)
    if env.done
        reset!(env)
        return env.state, -1., env.done
    end
    env.t += 1
    x, v = env.state
    v += (a - 2)*0.001 + cos(3*x)*(-0.0025)
    v = clamp(v, -env.params.maxspeed, env.params.maxspeed)
    x += v
    x = clamp(x, env.params.minpos, env.params.maxpos)
    if x == env.params.minpos && v < 0 v = 0 end
    env.done = x >= env.params.goalpos || env.t >= env.params.maxsteps
    env.state[1] = x
    env.state[2] = v
    (observe=env.state, reward=-1., isdone=env.done)
end