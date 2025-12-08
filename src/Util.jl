import Base: show
import Base: convert

import CxxWrap.CxxWrapCore: cxxdowncast

CxxWrap.@cxxdereference Base.show(io::IO, node::TNode) = print(io, to_string(node))
CxxWrap.@cxxdereference Base.show(io::IO, linarith::LinearArithExpr) = print(io, to_string(linarith))

function _reftype(x::CxxWrap.CxxWrapCore.CxxBaseRef{T}) ::Type{T} where T
    return typeof(x).parameters[1]
end

function _reftype(x::CxxWrap.CxxWrapCore.SmartPointer{T}) ::Type{T} where T
    return typeof(x).parameters[1]
end