using PyCall:@pyimport

@pyimport gym

function gymactor(name::String)
    pygymenv = gym.make(name)
    (method, args) -> begin
        if method == :reset 
            pygymenv[:reset]()
        end
    end
end
