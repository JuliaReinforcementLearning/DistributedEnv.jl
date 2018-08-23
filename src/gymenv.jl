struct DistributedEnv <: AbstractEnv
    name::String
    mailbox::RemoteChannel{Channel{Message}}
end

function DistributedEnv(name::String, pid=myid())
    mailbox = RemoteChannel(pid) do
        Channel(;csize=Inf) do c
            # TODO: catch exception
            while true
                msg = take!(c)
                put!(msg.resbox, gymactor(name)(msg.method, msg.args))
            end
        end
    end
    GymEnv(mailbox)
end

# function send(env::GymEnv, msgtype::Symbol, args...)
#     res = Future(GymEnv.pid)
#     put!(GymEnv.mailbox, (res, msgtype, args))
#     res
# end
