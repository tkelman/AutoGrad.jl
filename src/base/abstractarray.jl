# vect: Not exported
# oldstyle_vcat_warning: Not exported
# size: interfaces.jl
# eltype: interfaces.jl
# elsize: Not exported
# ndims: interfaces.jl
# length: interfaces.jl
# endof: interfaces.jl
# first: composite using start/next
# last: composite using getindex/endof
# stride: interfaces.jl
# strides: interfaces.jl
# isassigned: interfaces.jl
# trailingsize: Not exported
# linearindexing: Not exported
# checkbounds: interfaces.jl
# throw_boundserror: Not exported
# _internal_checkbounds: Not exported
# similar: interfaces.jl
# reshape
@primitive  reshape(x::AbstractArray,i...)  (dy->reshape(dy,size(x)))
fixdomain(::Fn{:reshape},x...)=(rand(2,2),(4,1))
# copy!: Overwriting operation
# copy: interfaces.jl
# copy_transpose!: Not exported
# zero: interfaces.jl
# start: interfaces.jl
# next: interfaces.jl
# done: interfaces.jl
# eachindex: interfaces.jl
# _maxlength: Not exported
# isempty: interfaces.jl
# convert: Cannot support.
# full
@primitive full(x::AbstractArray) identity
# map: Cannot support.
# pointer: interfaces.jl
# getindex: interfaces.jl
# unsafe_getindex: Not exported
# _getindex: Not exported
# _unsafe_getindex: Not exported
# setindex!: interfaces.jl, not supported
# unsafe_setindex!: Not exported
# _setindex!: Not exported
# _unsafe_setindex!: Not exported
# get (getindex with a default value)
# This can be left as a composite function, it will get its gradient from getindex if necessary.
get{T<:AbstractArray}(A::Node{T}, i::Integer, default) = checkbounds(Bool, length(A), i) ? A[i] : default
get{T<:AbstractArray}(A::Node{T}, I::Tuple{}, default) = similar(A, typeof(default), 0)
get{T<:AbstractArray}(A::Node{T}, I::Dims, default)    = checkbounds(Bool, size(A), I...) ? A[I...] : default
# get!: Overwriting function
# promote_eltype: Not exported

# cat(dims,A...): Concatenate the input arrays along the specified
# dimensions in the iterable dims. For dimensions not in dims, all
# input arrays should have the same size, which will also be the size
# of the output array along that dimension. For dimensions in dims,
# the size of the output array is the sum of the sizes of the input
# arrays along that dimension. If dims is a single number, the
# different arrays are tightly stacked along that dimension. If dims
# is an iterable containing several dimensions, this allows one to
# construct block diagonal matrices and their higher-dimensional
# analogues by simultaneously increasing several dimensions for every
# new input array and putting zero blocks elsewhere. For example,
# cat([1,2], matrices...) builds a block diagonal matrix, i.e. a block
# matrix with matrices[1], matrices[2], ... as diagonal blocks and
# matching zero blocks away from the diagonal.

# After catdims, cat can take 0 or more arguments of any type.  We
# only catch the cases where one of the first two args is a Node.

cat_r = recorder(cat)
cat(i,a::Node,b::Node,c...)=cat_r(i,a,b,c...)
cat(i,a,b::Node,c...)=cat_r(i,a,b,c...)
cat(i,a::Node,b...)=cat_r(i,a,b...)
cat{N}(g::Type{Grad{N}},y::Node,i::Node,x...)=cat(g,y,i.value,x...) # to avoid ambiguity
cat{N}(::Type{Grad{N}},y::Node,i,x...)=(dy->uncat(dy,N-1,i,x...))   # N-1 because first arg is catdims

# We need to extract the n'th block from dy which has the same shape
# as y=cat(catdims,x...).
# TODO: make uncat a primitive and define its gradient for higher order gradients.
function uncat(dy,n,catdims,x...)
    idx = []
    for d=1:ndims(dy)
        if in(d,catdims)
            pos = 0
            for j=1:n-1
                pos += size(x[j],d)
            end
            push!(idx,(pos+1):(pos+size(x[n],d)))
        else
            push!(idx,1:size(dy,d))
        end
    end
    dx = dy[idx...]
    if isa(getval(x[n]),AbstractArray)
        dx = reshape(dx, size(x[n]))
    else
        length(dx)==1 || error("uncat mismatch")
        dx = dx[1]
    end
    return dx
end

# Same deal with vcat and hcat, catch if one of the first two args is
# a Node.  We can leave these as composite using cat.

# vcat: vcat(X...) = cat(1, X...)
vcat(a::Node,b::Node,c...)=cat(1,a,b,c...)
vcat(a,b::Node,c...)=cat(1,a,b,c...)
vcat(a::Node,b...)=cat(1,a,b...)

# hcat: hcat(X...) = cat(2, X...)
hcat(a::Node,b::Node,c...)=cat(1,a,b,c...)
hcat(a,b::Node,c...)=cat(1,a,b,c...)
hcat(a::Node,b...)=cat(1,a,b...)

# typed_vcat: Not exported
# typed_hcat: Not exported
# cat_t: Not exported
# hvcat: TODO
# hvcat_fill: Not exported
# typed_hvcat: Not exported
# isequal: interfaces.jl
# lexcmp: interfaces.jl
# ==: interfaces.jl
# sub2ind: Not an array op.
# _sub2ind: Not exported
# ind2sub: Not an array op.
# ind2sub!: Not an array op.
# mapslices: Cannot support.
# promote_to!: Not exported
# map_promote: Not exported
# map!: Cannot support.
# map_to!: Not exported
# ith_all: Not exported
# map_n!: Not exported
# map_to_n!: Not exported
# push!: Overwriting function
# unshift!: Overwriting function
# hash: Works for Node.
