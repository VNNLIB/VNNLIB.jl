module VNNLIB

using CxxWrap

libpath() = joinpath(@__DIR__, "..", "build", "VNNLib_julia.so")

@wrapmodule(libpath)

function __init__()
    @initcxx
end

export parse_query, parse_query_str, check_query, check_query_str
export TElementType, TArithExpr, TVarExpr, TLiteral, TNegate, TPlus, TMinus, TMultiply
export TBoolExpr, TCompare, TConnective, TAssertion, TInputDefinition, THiddenDefinition, TOutputDefinition
export TNetworkDefinition, TVersion, TQuery

end # module
