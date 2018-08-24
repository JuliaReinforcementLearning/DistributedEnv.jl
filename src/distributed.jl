struct DistributedEnv <: AbstractEnv
    name::String
    mailbox::RemoteChannel{Channel{Message}}
end


function DistributedEnv(id::String, pid=myid())
    mailbox = RemoteChannel(pid) do
        Channel(;csize=Inf) do c
            # TODO: catch exception
            while true
                msg = take!(c)
                put!(msg.resbox, id2actor(id)(msg.method, msg.args))
            end
        end
    end
    GymEnv(id, mailbox)
end

whereis(env::DistributedEnv) = env.mailbox.where

function send(env::DistributedEnv, method::Symbol, args...)
    resbox = Future(whereis(env))
    put!(env.mailbox, Message(resbox, method, args))
    resbox
end
