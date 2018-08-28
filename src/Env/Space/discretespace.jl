struct DiscreteSpace <: AbstractSpace
    n::Int
end

"To compat with Python, here we start with 0"
sample(d::DiscreteSpace) = rand(0:d.n-1)
occursin(x::Int, d::DiscreteSpace) = 0 ≤ x < d.n
==(x::DiscreteSpace, y::DiscreteSpace) = x.n == y.n