
using VNNLIB 
using CxxWrap

CxxWrap.@cxxdereference function walk(n :: VNNLIB.LinearArithExprTerm; d=0)
    println(" "^d * "$(VNNLIB.typeof(n)): $(n)")
    println(" "^d * "Coefficient: $(VNNLIB.coeff(n))")
    println(" "^d * "Variable: $(VNNLIB.var(n))")
end

CxxWrap.@cxxdereference function walk(n :: VNNLIB.LinearArithExpr; d=0)
    println(" "^d * "$(VNNLIB.typeof(n)): $(n)")
    for term in VNNLIB.terms(n)
        walk(term, d=d+1)
    end
    println(" "^d * "Constant: $(VNNLIB.constant(n))")
end

CxxWrap.@cxxdereference function walk(n :: VNNLIB.TNode; d=0)
    if (
        typeof(n) <: VNNLIB.TArithExpr ||
        typeof(n) <: VNNLIB.TInputDefinition ||
        typeof(n) <: VNNLIB.TOutputDefinition ||
        typeof(n) <: VNNLIB.THiddenDefinition
       )
        t = " (dtype: $(VNNLIB.dtype(n)))"
    else 
        t = ""
    end
    println(" "^d * "$(VNNLIB.typeof(n)): $(n)$t")
    if typeof(n) <: VNNLIB.TArithExpr
        println(" "^d * " linearized:")
        walk(VNNLIB.linearize(n), d=d+1)
        println(" "^d * " --- ")
    end
    for c in VNNLIB.children(n)
        walk(c, d=d+1)
    end
end

parse_query(walk,"acc.vnnlib")

parse_query_str(walk, """
(vnnlib-version <2.0>)

(declare-network acc
	(declare-input X Real [3])
	(declare-output Y Real [])
)

(assert (<= (* -1.0 X[0]) 0.0))
""")