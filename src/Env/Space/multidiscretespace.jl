struct MultiDiscreteSpace{N} <:AbstractSpace
    counts::Array{Int, N}
end

size(s::MultiDiscreteSpace) = size(s.counts)

"To compat with Python, here we start with 0"
sample(s::MultiDiscreteSpace) = map(x -> rand(0:x-1), s.counts)
occursin(x::Int, s::MultiDiscreteSpace) = all(e -> 0 ≤ x < e, s.counts)
occursin(xs::Array{Int}, s::MultiDiscreteSpace) = size(s) == size(xs) &&
    all(map((e, x) -> 0 ≤ x < e , s.counts, xs))
==(x::MultiDiscreteSpace, y::MultiDiscreteSpace) = x.counts == y.counts