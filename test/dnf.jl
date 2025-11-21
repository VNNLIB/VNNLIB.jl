CxxWrap.@cxxdereference function get_bool(query :: TQuery)
    assertion = VNNLIB.assertions(query)[1]
    return expr(assertion)
end

function assert_dnf_equals(expected::Vector{Vector{String}}, actual::Vector{Vector{Union{CxxWrap.ConstCxxPtr{TGreaterThan},CxxWrap.ConstCxxPtr{TLessThan},CxxWrap.ConstCxxPtr{TGreaterEqual},CxxWrap.ConstCxxPtr{TLessEqual},CxxWrap.ConstCxxPtr{TEqual},CxxWrap.ConstCxxPtr{TNotEqual}}}})
    actual = CxxWrap.dereference_argument(actual)
    @test length(expected) == length(actual)
    for (i, expected_clause) in enumerate(expected)
        actual_clause = actual[i]
        @test length(expected_clause) == length(actual_clause)
        for (j, expected_expr) in enumerate(expected_clause)
            actual_expr_str = VNNLIB.to_string(actual_clause[j])
            @test expected_expr == actual_expr_str
            #println("Expected: $expected_expr, Actual: $actual_expr_str")
        end
    end
end

@testset "DNF" begin
    @testset "Single Literals" begin
        @testset "test_single_comparison" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= X[0] 10.0))
            """
            parse_query_str(content) do (ast)
                dnf = to_dnf(get_bool(ast))
                expected = [[ "(<= X [0] 10.0) "]]
                assert_dnf_equals(expected, dnf)
            end
        end
        @testset "test_simple_conjunction" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [2])
                (declare-output Y Real [1])
            )
            (assert (and (<= X[0] 10.0) (>= X[1] 5.0)))
            """
            parse_query_str(content) do (ast)
                dnf = to_dnf(get_bool(ast))
                expected = [[ "(<= X [0] 10.0) ", "(>= X [1] 5.0) "]]
                println(map(x->typeof.(x),dnf))
                assert_dnf_equals(expected, dnf)
            end
        end
        @testset "test_three_way_conjunction" begin
            
        end
    end
    
end