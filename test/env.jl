using DistributedEnv.Env

@testset "basic environments" begin
    @test "pygym#CartPole-v0" in keys(Env.supportedIDs)
    @test "atari#alien" in keys(Env.supportedIDs)

    for x in [CartPole, MountainCar, Pendulum]
        env = x()
        reset!(env)
        @test typeof(interact!(env, 1)) == NamedTuple{(:observe, :reward, :isdone),Tuple{Array{Float64,1},Float64,Bool}}
        @test typeof(getstate(env)) == NamedTuple{(:observe, :isdone),Tuple{Array{Float64,1},Bool}}
    end
end