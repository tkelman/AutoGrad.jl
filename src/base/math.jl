# These are functions defined in math.jl.  They can handle array arguments where
# they apply element-wise.  This is implemented in operators.jl using the
# @vectorize_1arg macro.  The values in the math1arg hash are expressions for
# dy/dx where y=f(x) and x,y can be arrays or scalars.  These expressions should
# be valid for array inputs.

math1arg = Dict{Symbol,Any}(
:acos => :(-1./sqrt(1-abs2(x))),	# domain: abs(x) <= 1; math,operators
:acosh => :(1./sqrt(abs2(x)-1)),        # domain: x >= 1; math,operators
:cbrt => :(1./(3.*abs2(y))),            # math,operators
:cos => :(-sin(x)),                     # math,operators
:deg2rad => :(pi/180),                  # math,operators
:exp => :y,                             # math,operators
:exp10 => :(y.*log(10)),                # math,operators
:exp2 => :(y.*log(2)),                  # math,operators
:expm1 => :(1+y),                       # math,operators
:exponent => 0,                         # returns int; math,operators
:log10 => :(1./(log(10).*x)),           # math,operators
:log1p => :(1./(1+x)),                  # math,operators
:log => :(1./x),                        # supports (N,) (A,) (N,N) (N,A) (A,N) (A,A); math,operators
:log2 => :(1./(log(2).*x)),             # math,operators
:rad2deg => :(180/pi),                  # math,operators
:sin => :(cos(x)),                      # math,operators
:sqrt => :(1./(2.*y)),                  # math,operators
:tan => :(1+abs2(y)),                   # math,operators
:tanh => :(1-abs2(y)),                  # math,operators
:asin => :todo,   # domain: abs(x) <= 1; math,operators
:asinh => :todo,  # math,operators
:atan => :todo,   # math,operators
:atanh => :todo,  # math,operators
:cosh => :todo,   # math,operators
:erf => :todo,  # math,operators
:erfc => :todo, # math,operators
:lgamma => :todo, # math,operators
:significand => :todo, # math,operators
:sinh => :todo,  # math,operators
)

defgrads(math1arg, Number)
defgrads(math1arg, AbstractArray)

for f in (:acosh,)
    testargs(::Fn{:acosh},a...)=map(x->1+abs(x), testargs(nothing,a))
end
for f in (:log1p,)
    testargs(::Fn{:acosh},a...)=map(x->-1+abs(x), testargs(nothing,a))
end
for f in (:log, :log2, :log10)
    testargs(::Fn{f},a...)=map(x->abs(x), testargs(nothing,a))
end
for f in (:acos, :asin)
    testargs(::Fn{f},a...)=map(x->sin(x), testargs(nothing,a))
end

# math2arg: These are functions that can handle mixing scalar and array
# arguments.  Some of these functions come from grepping
# vectorize_2arg in Base (defined in operators, used in fastmath,
# floatfuncs, math, bessel, gamma), which allows them to have Array
# arguments in first, second, or both positions.  When both arguments
# are Arrays they must have the same size, or if one has extra
# dimensions at the end they need to be 1.  The resulting array will
# have the longer of the two sizes.  (implemented by promote_shape).
# Note that no broadcasting is performed here, i.e. the two arrays
# need to have the same length.

# Similar 2arg functions are defined in arraymath (not using
# vectorize_2arg).

# Using variable names: y=f(x1,x2) in gradient definitions.  The
# math2arg dictionary returns a pair for each function specifying
# expressions to compute the first and second arg gradients.

# Unmarked functions below support the default signatures:
# (N,N) (N,A) (A,N) (A,A)
# Extra or missing argtypes are marked.
# where N:number, A:array, (A,B) different sized arrays.

math2arg = Dict{Symbol,Any}(
#:atan2 => :todo,                         # math,operators
#:hypot => :todo,                         # math,operators
#:log => :todo,                           # extra (N,) (A,); math,operators
:max => (:(y.==x1),:(y.==x2)),           # math,operators
:min => (:(y.==x1),:(y.==x2)),           # math,operators
)

defgrads(math2arg, Number, Number)
defgrads(math2arg, AbstractArray, Number)
defgrads(math2arg, Number, AbstractArray)
defgrads(math2arg, AbstractArray, AbstractArray)

math2arg1 = Dict{Symbol,Any}(
:^ => (:(x2.*x1.^(x2-1)),:(y.*log(x1))), # only supports (N,N), arrays not supported in math.jl, only M^N in linalg/dense.jl
#:minmax => :todo, # only supports (N,N); returns a tuple, cannot multiply dy with .*; math,operators
)                             

@primitive ^(x1::Node,x2::Integer) # to avoid clash with intfuncs:108
defgrads(math2arg, Number, Number)

# DEAD CODE:

# Each argument can be Number, Array, Node{Number}, Node{Array}
# (unfortunately it is not currently possible to specify
# Node{Array{Number}}.  If at least one argument is a Node, we call
# the recorder method.

# for (_f,_d) in math2arg
#     @eval begin
#         @primitive $_f(x1::Node, x2::Node)
#         @primitive $_f(x1::Node, x2::Union{Number,AbstractArray})
#         @primitive $_f(x1::Union{Number,AbstractArray},x2::Node)
#         $_f(::D1, y, x1, x2)=unbroadcast(y, x1, (dy->dy.*$(_d[1])))
#         $_f(::D2, y, x1, x2)=unbroadcast(y, x2, (dy->dy.*$(_d[2])))
#     end
# end

# # math2zerograd:
# # These functions have zero gradient either because they return boolean 
# # values or they truncate to an integer:

# math2zerograd = Dict{Symbol,Any}(
# )

# for (_f,_d) in math2zerograd
#     @eval begin
#         @zerograd $_f(x1::Node, x2::Node)
#         @zerograd $_f(x1::Node, x2::Number)
#         @zerograd $_f(x1::Node, x2::AbstractArray)
#         @zerograd $_f(x1::Number,x2::Node)
#         @zerograd $_f(x1::AbstractArray,x2::Node)
#     end
# end

# # TODO: look at broadcast.jl
# # TODO: transpose, reshape, concat, copy?
# # TODO: anything else in linalg?