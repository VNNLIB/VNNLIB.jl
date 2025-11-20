# A CxxWrap method that returns a super type (e.g. TNode) will always return that super type
# (or e.g. a vector thereof) even if the actual objects are of a derived type (e.g. TVarExpr).
# The functions in this file perform dynamic casting to return the most derived type possible.
# We keep the implementation intentionally general (so far targetting only CxxBaseRef{T})
# This would allow us to generalize this approach to Cxx SmartPointers if necessary
# and supported by CxxWrap.jl (not yet).
#
# The solution taken here is the one advised by:
# https://github.com/JuliaInterop/CxxWrap.jl/issues/493

function specialize_node(node :: CxxWrap.CxxWrapCore.CxxBaseRef{T}) where T<:TNode
    base_type = typeof(node).name.wrapper
    return _specialize_node(base_type, TNode, node)
end

function _specialize_node(::Type{T}, ::Type{TNode}, node) where T
    if convert(T{TArithExpr}, node) != C_NULL
        return _specialize_node(T, TArithExpr, node)
    elseif convert(T{TBoolExpr}, node) != C_NULL
        return _specialize_node(T, TBoolExpr, node)
    else
        element_type = convert(T{TElementType}, node)
        if element_type != C_NULL
            return element_type
        end
        assert = convert(T{TAssertion}, node)
        if assert != C_NULL
            return assert
        end
        input = convert(T{TInputDefinition}, node)
        if input != C_NULL
            return input
        end
        output = convert(T{TOutputDefinition}, node)
        if output != C_NULL
            return output
        end
        network = convert(T{TNetworkDefinition}, node)
        if network != C_NULL
            return network
        end
        version = convert(T{TVersion}, node)
        if version != C_NULL
            return version
        end
        query = convert(T{TQuery}, node)
        if query != C_NULL
            return query
        end
        hidden = convert(T{THiddenDefinition}, node)
        if hidden != C_NULL
            return hidden
        end
        return convert(T{TNode}, node)
    end
end

function _specialize_node(::Type{T}, ::Type{TArithExpr}, node) where T
    if convert(T{TLiteral}, node) != C_NULL
        return _specialize_node(T, TLiteral, node)
    end
    var = convert(T{TVarExpr}, node)
    if var != C_NULL
        return var
    end
    negate = convert(T{TNegate}, node)
    if negate != C_NULL
        return negate
    end
    plus = convert(T{TPlus}, node)
    if plus != C_NULL
        return plus
    end
    minus = convert(T{TMinus}, node)
    if minus != C_NULL
        return minus
    end
    multiply = convert(T{TMultiply}, node)
    if multiply != C_NULL
        return multiply
    end
    return convert(T{TArithExpr}, node)
end

function _specialize_node(::Type{T}, ::Type{TLiteral}, node) where T
    float = convert(T{TFloat}, node)
    if float != C_NULL
        return float
    end
    int = convert(T{TInt}, node)
    if int != C_NULL
        return int
    end
    return convert(T{TLiteral}, node)
end

function _specialize_node(::Type{T}, ::Type{TBoolExpr}, node) where T
    if convert(T{TCompare}, node) != C_NULL
        return _specialize_node(T, TCompare, node)
    elseif convert(T{TConnective}, node) != C_NULL
        return _specialize_node(T, TConnective, node)
    else
        return convert(T{TBoolExpr}, node)
    end
end

function _specialize_node(::Type{T}, ::Type{TCompare}, node) where T
    greater_than = convert(T{TGreaterThan}, node)
    if greater_than != C_NULL
        return greater_than
    end
    less_than = convert(T{TLessThan}, node)
    if less_than != C_NULL
        return less_than
    end
    greater_equal = convert(T{TGreaterEqual}, node)
    if greater_equal != C_NULL
        return greater_equal
    end
    less_equal = convert(T{TLessEqual}, node)
    if less_equal != C_NULL
        return less_equal
    end
    equal = convert(T{TEqual}, node)
    if equal != C_NULL
        return equal
    end
    not_equal = convert(T{TNotEqual}, node)
    if not_equal != C_NULL
        return not_equal
    end
    return convert(T{TCompare}, node)
end

function _specialize_node(::Type{T}, ::Type{TConnective}, node) where T
    and_node = convert(T{TAnd}, node)
    if and_node != C_NULL
        return and_node
    end
    or_node = convert(T{TOr}, node)
    if or_node != C_NULL
        return or_node
    end
    return convert(T{TConnective}, node)
end