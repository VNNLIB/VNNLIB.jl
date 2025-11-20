import Base: show
import Base: convert

import CxxWrap.CxxWrapCore: cxxdowncast

CxxWrap.@cxxdereference Base.show(io::IO, node::TNode) = print(io, to_string(node))

function _reftype(x::CxxWrap.CxxWrapCore.CxxBaseRef{T}) ::Type{T} where T
    return typeof(x).parameters[1]
end

function _reftype(x::CxxWrap.CxxWrapCore.SmartPointer{T}) ::Type{T} where T
    return typeof(x).parameters[1]
end


# The conversion functionalities below are not (yet) part of CxxWrap.jl 0.17.3,
# but will be available in future versions (which will allow us to remove this).
cxxdowncast(::Type{T}, x::ConstCxxPtr{BaseT}) where {BaseT, T <: BaseT} = ConstCxxPtr(cxxdowncast(T,CxxPtr(x)))

Base.convert(::Type{ConstCxxPtr{DerivedT}}, x::ConstCxxPtr{SuperT}) where {SuperT, DerivedT <: SuperT} = cxxdowncast(DerivedT, x)
Base.convert(::Type{ConstCxxPtr{DerivedT}}, x::CxxPtr{SuperT}) where {SuperT, DerivedT <: SuperT} = ConstCxxPtr(CxxWrap.CxxWrapCore.cxxdowncast(DerivedT, x))