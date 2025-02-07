using SymbolicUtils: SymbolicUtils

"""
    eval_tree_array(tree::Node, X::AbstractMatrix{T}, options::Options; kws...)

Evaluate a binary tree (equation) over a given input data matrix. The
operators contain all of the operators used. This function fuses doublets
and triplets of operations for lower memory usage.

This function can be represented by the following pseudocode:

```
function eval(current_node)
    if current_node is leaf
        return current_node.value
    elif current_node is degree 1
        return current_node.operator(eval(current_node.left_child))
    else
        return current_node.operator(eval(current_node.left_child), eval(current_node.right_child))
```
The bulk of the code is for optimizations and pre-emptive NaN/Inf checks,
which speed up evaluation significantly.

# Arguments
- `tree::Node`: The root node of the tree to evaluate.
- `X::AbstractMatrix{T}`: The input data to evaluate the tree on.
- `options::Options`: Options used to define the operators used in the tree.

# Returns
- `(output, complete)::Tuple{AbstractVector{T}, Bool}`: the result,
    which is a 1D array, as well as if the evaluation completed
    successfully (true/false). A `false` complete means an infinity
    or nan was encountered, and a large loss should be assigned
    to the equation.
"""
function eval_tree_array(tree::Node{T}, X::AbstractArray{T}, options::Options; kws...) where {T}
    return eval_tree_array(tree, X, options.operators; kws...)
end

"""
    eval_diff_tree_array(tree::Node{T}, X::AbstractMatrix{T}, options::Options, direction::Int)

Compute the forward derivative of an expression, using a similar
structure and optimization to eval_tree_array. `direction` is the index of a particular
variable in the expression. e.g., `direction=1` would indicate derivative with
respect to `x1`.

# Arguments

- `tree::Node`: The expression tree to evaluate.
- `X::AbstractMatrix{T}`: The data matrix, with each column being a data point.
- `options::Options`: The options containing the operators used to create the `tree`.
    `enable_autodiff` must be set to `true` when creating the options.
    This is needed to create the derivative operations.
- `direction::Int`: The index of the variable to take the derivative with respect to.

# Returns

- `(evaluation, derivative, complete)::Tuple{AbstractVector{T}, AbstractVector{T}, Bool}`: the normal evaluation,
    the derivative, and whether the evaluation completed as normal (or encountered a nan or inf).
"""
function eval_diff_tree_array(
    tree::Node{T}, X::AbstractArray{T}, options::Options, direction::Int
) where {T}
    return eval_diff_tree_array(tree, X, options.operators, direction)
end

"""
    eval_grad_tree_array(tree::Node{T}, X::AbstractMatrix{T}, options::Options; variable::Bool=false)

Compute the forward-mode derivative of an expression, using a similar
structure and optimization to eval_tree_array. `variable` specifies whether
we should take derivatives with respect to features (i.e., `X`), or with respect
to every constant in the expression.

# Arguments

- `tree::Node{T}`: The expression tree to evaluate.
- `X::AbstractMatrix{T}`: The data matrix, with each column being a data point.
- `options::Options`: The options containing the operators used to create the `tree`.
    `enable_autodiff` must be set to `true` when creating the options.
    This is needed to create the derivative operations.
- `variable::Bool`: Whether to take derivatives with respect to features (i.e., `X` - with `variable=true`),
    or with respect to every constant in the expression (`variable=false`).

# Returns

- `(evaluation, gradient, complete)::Tuple{AbstractVector{T}, AbstractMatrix{T}, Bool}`: the normal evaluation,
    the gradient, and whether the evaluation completed as normal (or encountered a nan or inf).
"""
function eval_grad_tree_array(tree::Node{T}, X::AbstractArray{T}, options::Options; kws...) where {T}
    return eval_grad_tree_array(tree, X, options.operators; kws...)
end

"""
    differentiable_eval_tree_array(tree::Node{T}, X::AbstractMatrix{T}, options::Options)

Evaluate an expression tree in a way that can be auto-differentiated.
"""
function differentiable_eval_tree_array(
    tree::Node{T}, X::AbstractArray{T}, options::Options; kws...
) where {T}
    return differentiable_eval_tree_array(tree, X, options.operators; kws...)
end

"""
    string_tree(tree::Node, options::Options; kws...)

Convert an equation to a string.

# Arguments

- `tree::Node`: The equation to convert to a string.
- `options::Options`: The options holding the definition of operators.
- `varMap::Union{Array{String, 1}, Nothing}=nothing`: what variables
    to print for each feature.
"""
function string_tree(tree::Node, options::Options; kws...)
    return string_tree(tree, options.operators; kws...)
end

"""
    print_tree(tree::Node, options::Options; kws...)

Print an equation

# Arguments

- `tree::Node`: The equation to convert to a string.
- `options::Options`: The options holding the definition of operators.
- `varMap::Union{Array{String, 1}, Nothing}=nothing`: what variables
    to print for each feature.
"""
function print_tree(tree::Node, options::Options; kws...)
    return print_tree(tree, options.operators; kws...)
end
function print_tree(io::IO, tree::Node, options::Options; kws...)
    return print_tree(io, tree, options.operators; kws...)
end

"""
    convert(::Type{Node{T}}, tree::Node, options::Options; kws...)

Convert an equation to a different base type `T`.
"""
function Base.convert(::Type{Node{T}}, tree::Node, options::Options) where {T}
    return convert(Node{T}, tree, options.operators)
end

function Base.convert(
    s::typeof(SymbolicUtils.Symbolic), tree::Node, options::Options; kws...
)
    return convert(s, tree, options.operators; kws...)
end

function Base.convert(
    n::typeof(Node), x::Union{Number,SymbolicUtils.Symbolic}, options::Options; kws...
)
    return convert(n, x, options.operators; kws...)
end

"""
    node_to_symbolic(tree::Node, options::Options; kws...)

Convert an expression to SymbolicUtils.jl form. 
"""
function node_to_symbolic(tree::Node, options::Options; kws...)
    return node_to_symbolic(tree, options.operators; kws...)
end

"""
    node_to_symbolic(eqn::T, options::Options; kws...) where {T}

Convert a SymbolicUtils.jl expression to SymbolicRegression.jl's `Node` type.
"""
function symbolic_to_node(
    eqn::T, options::Options; kws...
) where {T<:SymbolicUtils.Symbolic}
    return symbolic_to_node(eqn, options.operators; kws...)
end
