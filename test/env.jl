using DistributedEnv.Env

@testset "basic environments" begin
    @test "pygym#CartPole-v0" in keys(Env.supportedIDs)
    @test "atari#alien" in keys(Env.supportedIDs)
end