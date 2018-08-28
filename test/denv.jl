using DistributedEnv
using Distributed

@testset "DistributedEnv" begin
    env = init_env("pygym#CartPole-v0")
    @test isopen(env[1].mailbox)
end