# DistributedEnv.jl

This package aims to provide a uniformed interface for different kinds of reinforcement learning environments to run in parallel.

## Supported Environments

| Category | Install Requirement | Description |
|-----|-------------|--------------|
| classic | Builtin | Including Cartpole, MountainCar and Pendulum |
|[Atari](https://github.com/JuliaReinforcementLearning/ArcadeLearningEnvironment.jl) | Builtin |  Supported by `ccall` |
|[ViZDoom](https://github.com/JuliaReinforcementLearning/ViZDoom.jl) | Install [dependencies](https://github.com/mwydmuch/ViZDoom/blob/master/doc/Building.md#-linux) first | Supported by [CxxWrap](https://github.com/JuliaInterop/CxxWrap.jl) |
|[OpenAi Gym](https://github.com/openai/gym) | Install [gym](https://github.com/openai/gym#installation) first | Supported by [PyCall](https://github.com/JuliaPy/PyCall.jl) |

## Install

First, install all the required dependencies in the above table. Then add this package

```
(v1.0) pkg> add https://github.com/findmyway/DistributedEnv.jl
```

## Example

```julia
julia> using Distributed

julia> addprocs(4)
4-element Array{Int64,1}:
 2
 3
 4
 5

julia> @everywhere using DistributedEnv

julia> envs = init_env("pygym#CartPole-v0")
4-element Array{DEnv,1}:
 DEnv("pygym#CartPole-v0", RemoteChannel{Channel{DistributedEnv.Message}}(2, 1, 14), DiscreteSpace(2, 0))
 DEnv("pygym#CartPole-v0", RemoteChannel{Channel{DistributedEnv.Message}}(3, 1, 19), DiscreteSpace(2, 0))
 DEnv("pygym#CartPole-v0", RemoteChannel{Channel{DistributedEnv.Message}}(4, 1, 24), DiscreteSpace(2, 0))
 DEnv("pygym#CartPole-v0", RemoteChannel{Channel{DistributedEnv.Message}}(5, 1, 29), DiscreteSpace(2, 0))

julia> states = [reset!(x) |> fetch for x in envs]
4-element Array{PyCall.PyObject,1}:
 PyObject array([ 0.03550486,  0.0211674 ,  0.02136902, -0.02979357])
 PyObject array([ 0.00539775,  0.01115946,  0.04614764, -0.01122543])
 PyObject array([-0.02346277,  0.0265993 , -0.03072315, -0.01011673])
 PyObject array([ 0.04320456,  0.04457253,  0.02651887, -0.02386143])

julia> states = [interact!(x, actionspace(x) |>sample) |> fetch for x in envs]
4-element Array{NamedTuple{(:observe, :reward, :isdone),Tuple{Array{Float64,1},Float64,Bool}},1}:
 (observe = [0.0359282, 0.215976, 0.0207732, -0.315658], reward = 1.0, isdone = false)
 (observe = [0.00562094, 0.20559, 0.0459231, -0.288999], reward = 1.0, isdone = false)
 (observe = [-0.0229308, -0.168069, -0.0309255, 0.272717], reward = 1.0, isdone = false)
 (observe = [0.044096, -0.150919, 0.0260416, 0.277069], reward = 1.0, isdone = false)
 ```

Notice that all the states are fetched to LocalProcess here. In practice, you'd better provide an actor on worker process to reduce data transfer.

Obviously, you can just play with a single environment here. Note that the game id here is without the category prefix.

```julia
julia> using DistributedEnv
[ Info: Precompiling DistributedEnv [4c74d760-a68f-11e8-0c49-2ba71e3afc10]

julia> env = AtariEnv("alien")
A.L.E: Arcade Learning Environment (version 0.6.0)
[Powered by Stella]
Use -help for help screen.
Warning: couldn't load settings file: ./ale.cfg
Game console created:
  ROM file:  /home/tj/.julia/packages/ArcadeLearningEnvironment/3cKG0/src/../deps/roms/alien.bin
  Cart Name: Alien (1982) (20th Century Fox)
  Cart MD5:  f1a0a23e6464d954e3a9579c4ccd01c8
  Display Format:  AUTO-DETECT ==> NTSC
  ROM Size:        4096
  Bankswitch Type: AUTO-DETECT ==> 4K


WARNING: Possibly unsupported ROM: mismatched MD5.
Cartridge_MD5: f1a0a23e6464d954e3a9579c4ccd01c8
Cartridge_name: Alien (1982) (20th Century Fox)

Running ROM file...
Random seed is 0
AtariEnv(Ptr{Nothing} @0x0000000002a4ecd0, UInt8[0x48, 0xdd, 0x7c, 0x01, 0x00, 0x00, 0x00, 0x00, 0xf6, 0xdd  …  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], ArcadeLearningEnvironment.getScreenGrayscale, Int32[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17], DiscreteSpace(18, 1), 20)

julia> reset!(env)
33600-element Array{UInt8,1}:
 0x00
 0x00
 0x00
 0x00
 0x00
 0x00
 0x00
 0x00
    ⋮
 0x00
 0x00
 0x00
 0x00
 0x00
 0x00
 0x00
 0x00

julia> interact!(env, sample(actionspace(env)))
(observe = UInt8[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  …  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], reward = 0, isdone = false)
```

To list all the supported environment IDs:

```julia
julia> keys(DistributedEnv.Env.supportedIDs)
Base.KeySet for a Dict{String,Any} with 864 entries. Keys:
  "pygym#IceHockeyNoFrameskip-v4"
  "pygym#KangarooDeterministic-v4"
  "pygym#PooyanNoFrameskip-v0"
  "atari#elevator_action"
  "pygym#DemonAttack-ram-v4"
  "pygym#HandManipulatePen-v0"
  "pygym#Enduro-ramDeterministic-v4"
  "pygym#MountainCarContinuous-v0"
  "pygym#Centipede-ram-v4"
  "pygym#NameThisGame-ramNoFrameskip-v4"
  "pygym#ElevatorActionNoFrameskip-v4"
  "pygym#IceHockeyDeterministic-v4"
  "pygym#DoubleDunk-v4"
  "pygym#YarsRevenge-ramNoFrameskip-v0"
  "pygym#AirRaid-ramDeterministic-v0"
  "pygym#Hero-ramNoFrameskip-v0"
  ⋮
```