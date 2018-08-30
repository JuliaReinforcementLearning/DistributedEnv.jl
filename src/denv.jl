using Distributed
using .Env

export DEnv, whereis, send

struct DEnv <: AbstractDistributedEnv
    id::String
    mailbox::RemoteChannel{Channel{Message}}
    actionspace::AbstractSpace
end


function DEnv(id::String, pid::Int=myid(); kw...)
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
    actionspace = send(mailbox, "actionspace") |> fetch
    DEnv(id, mailbox, actionspace)
end

whereis(env::DEnv) = env.mailbox.where

function send(mailbox::RemoteChannel{Channel{Message}} , method::String, args...; kw...)
    resbox = Future(mailbox.where)
    put!(mailbox, Message(resbox, method, args, kw))
    resbox
end

send(env::DEnv, method::String, args...; kw...) = send(env.mailbox, method, args...; kw...)