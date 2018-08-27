using Distributed
using .Env

struct DEnv <: AbstractDistributedEnv
    id::String
    mailbox::RemoteChannel{Channel{Message}}
end


function DEnv(id::String, pid::Int; kw...)
    mailbox = RemoteChannel(pid) do
        Channel(;ctype=Message, csize=Inf) do c
            try
                env = id2env(id; kw...)
                while true
                    msg = take!(c)
                    put!(msg.resbox, receive(env, msg.method, msg.args, msg.kw))
                end
            catch e
                @error e
            end
        end
    end
    DEnv(id, mailbox)
end

whereis(env::DEnv) = env.mailbox.where

function send(env::DEnv, method::String, args...; kw...)
    resbox = Future(whereis(env))
    put!(env.mailbox, Message(resbox, method, args, kw))
    resbox
end
