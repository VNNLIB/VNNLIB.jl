module VNNLIB

using CxxWrap

include("Internal.jl")

using .VNNLIBCore

export parse_query, parse_query_str, check_query, check_query_str
export children
export dtype

export SymbolInfo
export TNode
export TElementType

export TArithExpr, dtype, linearize

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

export LinearArithExpr, terms, constant
export LinearArithExprTerm, coeff, var, var_name

include("Util.jl")

include("Typing.jl")


function parse_query(f, filepath::String)
    ast = VNNLIBCore.parse_query(filepath)
    GC.@preserve ast begin
        result = f(ast)
    end
    return result
end

function parse_query_str(f, content::String)
    ast = VNNLIBCore.parse_query_str(content)
    GC.@preserve ast begin
        result = f(ast)
    end
    return result
end

CxxWrap.@cxxdereference function children(node::TNode)
    return specialize_node.(VNNLIBCore.children(node))
end

end # module
