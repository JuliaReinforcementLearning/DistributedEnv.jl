using Distributed

struct DEnv <: AbstractEnv
    id::String
    mailbox::RemoteChannel{Channel{Message}}
end


function DEnv(id::String, pid::Int)
    mailbox = RemoteChannel(pid) do
        Channel(;ctype=Message, csize=Inf) do c
            # TODO: catch exception
            while true
                msg = take!(c)
                put!(msg.resbox, Env.id2env(id)(msg.method, msg.args))
            end
        end
    end
    DEnv(id, mailbox)
end

whereis(env::DEnv) = env.mailbox.where

function send(env::DEnv, method::Symbol, args...)
    resbox = Future(whereis(env))
    put!(env.mailbox, Message(resbox, method, args))
    resbox
end
