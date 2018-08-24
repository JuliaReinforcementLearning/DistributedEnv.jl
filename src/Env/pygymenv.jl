using PyCall
@pyimport gym

function pygymenv(id::String)
    env = gym.make(id)
    (method, args) -> begin
        if method == :reset 
            env[:reset]()
        end
    end
end

pygymids() = [x[:id] for x in gym.envs[:registry][:all]()]