module VNNLIB

using CxxWrap

include("Internal.jl")

using .VNNLIBCore

export parse_query, parse_query_str, check_query, check_query_str
export children, args, expr, lhs, rhs, to_dnf
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

export TNetworkDefinition, net_isometric_to, net_equal_to, net_inputs, net_outputs, net_hidden

export TVersion

export TQuery, networks, assertions

export LinearArithExpr, terms, constant
export LinearArithExprTerm, coeff, var, var_name

export Polytope, coeff_matrix #, rhs
export SpecCase, input_box, output_constraints

export transform_to_compat

export Solver, verify
export VerificationResult, SolverSat, SolverUnsat, SolverUnknown, SolverTimedOut

export HiddenNodeTheory, HiddenNH, HiddenH
export MultipleInputOutputTheory, InputOutputSIO, InputOutputMIO
export MultipleNetworkTheory, NetworkSNET, NetworkMENET, NetworkMINET, NetworkMNET
export MultipleNodeComparisonTheory, NodeComparisonSNC, NodeComparisonMNC
export ArithmeticComplexityTheory, ArithmeticBND, ArithmeticOUTC, ArithmeticLIN, ArithmeticPOLY

export SemanticVersion, major, minor, patch, extra
export VersionRange, minimum_version, maximum_version
export OpsetRange, minimum_opset, maximum_opset
export OperatorSupport, operator_name, element_types

export supports_onnx_opset_versions
export supports_onnx_element_types
export supports_onnx_operators
export supports_vnnlib_versions
export supports_hidden_node_theories
export supports_multiple_input_output_theories
export supports_multiple_network_theories
export supports_multiple_node_comparison_theories
export supports_arithmetic_complexity_theories
export supports_optimised_disjunctive_reasoning
export supports_serialise_assignments

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

CxxWrap.@cxxdereference function to_dnf(expr::TBoolExpr) :: Vector{Vector{Union{CxxWrap.ConstCxxPtr{TGreaterThan},CxxWrap.ConstCxxPtr{TLessThan},CxxWrap.ConstCxxPtr{TGreaterEqual},CxxWrap.ConstCxxPtr{TLessEqual},CxxWrap.ConstCxxPtr{TEqual},CxxWrap.ConstCxxPtr{TNotEqual}}}}
    return map(x->specialize_node.(x), VNNLIBCore.to_dnf(expr))
end


function verify(
    solver::Solver,
    query::AbstractString,
    networks::AbstractDict{<:AbstractString,<:AbstractString},
    timeout::Union{Nothing,Integer}=nothing
)
    network_names = CxxWrap.StdLib.StdVector{CxxWrap.StdLib.StdString}()
    network_paths = CxxWrap.StdLib.StdVector{CxxWrap.StdLib.StdString}()

    for (name, path) in networks
        push!(network_names, CxxWrap.StdLib.StdString(String(name)))
        push!(network_paths, CxxWrap.StdLib.StdString(String(path)))
    end

    if isnothing(timeout)
        return VNNLIBCore.verify_no_timeout(
            solver,
            String(query),
            network_names,
            network_paths
        )
    end

    return VNNLIBCore.verify_with_timeout(
        solver,
        String(query),
        network_names,
        network_paths,
        Int(timeout)
    )
end


function patch(version::SemanticVersion)
    if VNNLIBCore.has_patch(version)
        return VNNLIBCore.patch_value(version)
    end

    return nothing
end


end # module
