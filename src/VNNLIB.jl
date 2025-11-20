module VNNLIB

using CxxWrap

include("Internal.jl")

using .VNNLIBCore

export parse_query, parse_query_str, check_query, check_query_str
export children

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
