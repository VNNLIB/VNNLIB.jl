module VNNLIBCore
# To make VNNLIB.jl compatible with some Julia and CxxWrap.jl quirks,
# we wrap certain functions in VNNLIB
# Not exporting them here keeps the namespace of VNNLIB clean.

# Memory Management
#
# For VNNLIB.jl we assume that top-level functions that generate ASTs (load_query, load_query_str)
# are used in a way that ensures proper memory management using GC.@preserve.
# To this end, we provide context managers for load_query and load_query_str in VNNLIB.jl.
# We expose raw pointers for internal objects derived from the generated AST.
# Hence, users of VNNLIB.jl should only rely on these objects while their AST is alive
# (either by using our context managers or by ensuring that the AST object
# is not garbage collected on their own).

using CxxWrap

libpath() = joinpath(@__DIR__, "..", "build", "VNNLib_julia.so")

@wrapmodule(libpath)

function __init__()
    @initcxx
end

export check_query, check_query_str
export SymbolInfo
export TNode, to_string
export TElementType

export TArithExpr

export TVarExpr

export TLiteral
export TFloat
export TInt

export TNegate
export TPlus
export TMinus
export TMultiply

export TBoolExpr
export TCompare

export TGreaterThan
export TLessThan
export TGreaterEqual
export TLessEqual
export TEqual
export TNotEqual

export TConnective
export TAnd
export TOr

export TAssertion

export TInputDefinition
export THiddenDefinition
export TOutputDefinition

export TNetworkDefinition

export TVersion

export TQuery

end