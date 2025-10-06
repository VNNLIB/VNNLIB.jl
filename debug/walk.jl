
using VNNLIB 

function walk(n; d=0)
    println(" "^d * "$(typeof(n).parameters[1]): $(VNNLIB.to_string(n))")
    for c in VNNLIB.children(n)
        walk(c, d=d+1)
    end
end

ast = parse_query(joinpath(@__DIR__, "..", "..", "VNNLIB-Standard", "test", "acc.vnnlib"))
walk(ast)

