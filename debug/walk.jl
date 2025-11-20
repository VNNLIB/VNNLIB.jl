
using VNNLIB 

function walk(n; d=0)
    println(" "^d * "$(VNNLIB._reftype(n)): $(n)")
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