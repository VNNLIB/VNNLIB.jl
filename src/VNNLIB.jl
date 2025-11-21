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

export TVarExpr, name, onnx_name, shape, kind, network_name, indices, line

export TLiteral, lexeme, line
export TFloat, value
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

CxxWrap.@cxxdereference function args(expr::TPlus)
    return specialize_node.(VNNLIBCore.args(expr))
end

CxxWrap.@cxxdereference function args(expr::TMinus)
    return specialize_node.(VNNLIBCore.args(expr))
end

CxxWrap.@cxxdereference function args(expr::TMultiply)
    return specialize_node.(VNNLIBCore.args(expr))
end

CxxWrap.@cxxdereference function args(expr::TConnective)
    return specialize_node.(VNNLIBCore.args(expr))
end

CxxWrap.@cxxdereference function expr(neg::TNegate)
    return specialize_node(VNNLIBCore.expr(neg))
end

CxxWrap.@cxxdereference function lhs(cmp::TCompare)
    return specialize_node(VNNLIBCore.lhs(cmp))
end

CxxWrap.@cxxdereference function rhs(cmp::TCompare)
    return specialize_node(VNNLIBCore.rhs(cmp))
end

CxxWrap.@cxxdereference function rhs(poly::Polytope)
    return VNNLIBCore.rhs(poly)
end

CxxWrap.@cxxdereference function expr(assertion::TAssertion)
    return specialize_node(VNNLIBCore.expr(assertion))
end

CxxWrap.@cxxdereference function to_dnf(expr::TBoolExpr)
    return map(x->specialize_node.(x), VNNLIBCore.to_dnf(expr))
end

end # module
