using MLStyle

include("cartpole.jl")
include("mountaincar.jl")
include("pendulum.jl")

classicenv(id::String; kw...) = @match id begin
    "cartpole"    => CartPole(;kw...)
    "mountaincar" => MountainCar(;kw...)
    "pendulum"    => Pendulum(;kw...)
end