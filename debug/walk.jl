
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

CxxWrap.@cxxdereference function walk(n :: VNNLIB.TNode; d=0, dnf=true)
    if (
        typeof(n) <: VNNLIB.TArithExpr ||
        typeof(n) <: VNNLIB.TInputDefinition ||
        typeof(n) <: VNNLIB.TOutputDefinition ||
        typeof(n) <: VNNLIB.THiddenDefinition
       )
        t = "dtype: $(VNNLIB.dtype(n))"
        if typeof(n) <: VNNLIB.TVarExpr ||
        typeof(n) <: VNNLIB.TInputDefinition ||
        typeof(n) <: VNNLIB.TOutputDefinition ||
        typeof(n) <: VNNLIB.THiddenDefinition
            t *= "; name: $(VNNLIB.name(n))"
            t *= "; onnx_name: $(VNNLIB.onnx_name(n))"
            t *= "; shape: $(VNNLIB.shape(n))"
            t *= "; kind: $(VNNLIB.kind(n))"
            t *= "; network_name: $(VNNLIB.network_name(n))"
        end
        if typeof(n) <: VNNLIB.TVarExpr
            t *= "; indices: $(VNNLIB.indices(n))"
            t *= "; line: $(VNNLIB.line(n))"
        end
        if typeof(n) <: VNNLIB.TLiteral
            t *= "; lexeme: $(VNNLIB.lexeme(n))"
            t *= "; line: $(VNNLIB.line(n))"
        end
        if typeof(n) <: VNNLIB.TFloat || typeof(n) <: VNNLIB.TInt
            t *= "; value: $(VNNLIB.value(n))"
        end
        if typeof(n) <: VNNLIB.TNegate
            t *= "; expr: $(VNNLIB.expr(n))"
        end
        if typeof(n) <: VNNLIB.TPlus || typeof(n) <: VNNLIB.TMinus || typeof(n) <: VNNLIB.TMultiply
            t *= "; args: $(VNNLIB.args(n))"
        end
    elseif typeof(n) <: VNNLIB.TConnective
        t = "args: $(VNNLIB.args(n))"
    elseif typeof(n) <: VNNLIB.TCompare
        t = "left: $(VNNLIB.lhs(n)); right: $(VNNLIB.rhs(n))"
    elseif typeof(n) <: VNNLIB.TAssertion
        t = "expr: $(VNNLIB.expr(n))"
    elseif typeof(n) <: VNNLIB.TNetworkDefinition
        t = "isometric_to: $(VNNLIB.net_isometric_to(n)); equal_to: $(VNNLIB.net_equal_to(n)); inputs: $(VNNLIB.net_inputs(n)); outputs: $(VNNLIB.net_outputs(n)); hidden: $(VNNLIB.net_hidden(n))"
    elseif typeof(n) <: VNNLIB.TVersion
        t = "major: $(VNNLIB.version_major(n)); minor: $(VNNLIB.version_minor(n))"
    elseif typeof(n) <: VNNLIB.TQuery
        t = "networks: $(VNNLIB.networks(n)); assertions: $(VNNLIB.assertions(n))"
    else 
        t = ""
    end
    if typeof(n) <: VNNLIB.TBoolExpr && dnf
        println(" "^d * "$(VNNLIB.typeof(n)): $(n)")
        println(" "^d * " $t")
        println(" "^d * " --- DNF Form --- ")
        dnf = VNNLIB.to_dnf(n)
        for clause in dnf
            println(" "^(d+1) * "Clause:")
            for comp in clause
                walk(comp; d=d+2, dnf=false)
            end
        end
        println(" "^d * " --- End DNF Form --- ")
    else
        println(" "^d * "$(VNNLIB.typeof(n)): $(n)")
        if length(t) > 0
            println(" "^d * " $t")
        end
        if typeof(n) <: VNNLIB.TArithExpr
            println(" "^d * " linearized:")
            walk(VNNLIB.linearize(n), d=d+1)
            println(" "^d * " --- ")
        end
        for c in VNNLIB.children(n)
            walk(c, d=d+1)
        end
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

println("------------ Compat -----------")
parse_query("compat.vnnlib") do (ast)
    for spec_case in VNNLIB.transform_to_compat(ast)
        println("SpecCase:")
        println(" Input Box: $(VNNLIB.input_box(spec_case))")
        println(" Output Constraints:")
        for polytope in VNNLIB.output_constraints(spec_case)
            println("  Polytope: Coeff Matrix: $(VNNLIB.coeff_matrix(polytope))")
            println("  Polytope: RHS: $(VNNLIB.rhs(polytope))")
        end
    end
end