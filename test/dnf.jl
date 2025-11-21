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
                assert_dnf_equals(expected, dnf)
            end
        end
        @testset "test_three_way_conjunction" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [3])
                (declare-output Y Real [1])
            )
            (assert (and (<= X[0] 10.0) (>= X[1] 5.0) (<= X[2] 20.0)))
            """
            parse_query_str(content) do (ast)
                dnf = to_dnf(get_bool(ast))
                expected = [[ "(<= X [0] 10.0) ", "(>= X [1] 5.0) ", "(<= X [2] 20.0) "]]
                assert_dnf_equals(expected, dnf)
            end
        end
    end
    @testset "Disjunction Tests" begin
        @testset "test_simple_disjunction" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [2])
                (declare-output Y Real [1])
            )
            (assert (or (<= X[0] 10.0) (>= X[1] 5.0)))
            """
            parse_query_str(content) do (ast)
                dnf = to_dnf(get_bool(ast))
                expected = [[ "(<= X [0] 10.0) "], ["(>= X [1] 5.0) "]]
                assert_dnf_equals(expected, dnf)
            end
        end
        @testset "test_three_way_disjunction" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [3])
                (declare-output Y Real [1])
            )
            (assert (or (<= X[0] 10.0) (>= X[1] 5.0) (<= X[2] 0.0)))
            """
            parse_query_str(content) do (ast)
                dnf = to_dnf(get_bool(ast))
                expected = [[ "(<= X [0] 10.0) "], ["(>= X [1] 5.0) "], ["(<= X [2] 0.0) "]]
                assert_dnf_equals(expected, dnf)
            end
        end
        @testset "test_and_of_ors" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [3])
                (declare-output Y Real [3])
            )
            (assert (and (or (<= X[0] 10.0) (>= X[1] 5.0)) 
                        (or (<= X[2] 20.0) (>= Y[0] 15.0))
                        (or (<= Y[1] 30.0) (>= Y[2] 25.0))))
            """
            parse_query_str(content) do (ast)
                dnf = to_dnf(get_bool(ast))
                expected = [
                    [ "(<= X [0] 10.0) ", "(<= X [2] 20.0) ", "(<= Y [1] 30.0) "],
                    [ "(<= X [0] 10.0) ", "(<= X [2] 20.0) ", "(>= Y [2] 25.0) "],
                    [ "(<= X [0] 10.0) ", "(>= Y [0] 15.0) ", "(<= Y [1] 30.0) "],
                    [ "(<= X [0] 10.0) ", "(>= Y [0] 15.0) ", "(>= Y [2] 25.0) "],
                    [ "(>= X [1] 5.0) ", "(<= X [2] 20.0) ", "(<= Y [1] 30.0) "],
                    [ "(>= X [1] 5.0) ", "(<= X [2] 20.0) ", "(>= Y [2] 25.0) "],
                    [ "(>= X [1] 5.0) ", "(>= Y [0] 15.0) ", "(<= Y [1] 30.0) "],
                    [ "(>= X [1] 5.0) ", "(>= Y [0] 15.0) ", "(>= Y [2] 25.0) "]
                ]
                assert_dnf_equals(expected, dnf)
            end
        end
    end
    @testset "Complex Nested Expressions" begin
        @testset "test_nested_expression" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [4])
                (declare-output Y Real [2])
            )
            (assert (and (or (<= X[0] 10.0) (and (>= X[1] 5.0) (<= X[2] 15.0))) 
                        (or (>= Y[0] 20.0) (<= Y[1] 25.0))))
            """
            parse_query_str(content) do (ast)
                dnf = to_dnf(get_bool(ast))
                expected = [
                    [ "(<= X [0] 10.0) ", "(>= Y [0] 20.0) "],
                    [ "(<= X [0] 10.0) ", "(<= Y [1] 25.0) "],
                    [ "(>= X [1] 5.0) ", "(<= X [2] 15.0) ", "(>= Y [0] 20.0) "],
                    [ "(>= X [1] 5.0) ", "(<= X [2] 15.0) ", "(<= Y [1] 25.0) "]
                ]
                assert_dnf_equals(expected, dnf)
            end
        end
    end
    @testset "test_complex_arithmetic" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [2])
            (declare-output Y Real [1])
        )
        (assert (and (<= (+ X[0] X[1]) 10.0) (>= (* -1.0 X[0]) -5.0)))
        """
        parse_query_str(content) do (ast)
            dnf = to_dnf(get_bool(ast))
            expected = [
                [ "(<= (+ X [0] X [1]) 10.0) ", "(>= (* -1.0 X [0]) -5.0) "]
            ]
            assert_dnf_equals(expected, dnf)
        end
    end
    
end