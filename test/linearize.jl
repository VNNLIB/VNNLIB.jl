CxxWrap.@cxxdereference function get_lhs(query :: TQuery)
    assertion = VNNLIB.assertions(query)[1]
    comparison = children(assertion)[1]
    left = VNNLIB.lhs(comparison)
    return left
end

CxxWrap.@cxxdereference function check_linear_expr(
    linear_expr :: LinearArithExpr,
    expected_constant :: Float64,
    expected_terms)
    @test isapprox(constant(linear_expr), expected_constant; atol=1e-9)
    linear_terms = terms(linear_expr)
    @test length(linear_terms) == length(expected_terms)
    expected = [(exp_coeff, exp_var_name) for (exp_coeff, exp_var_name) in expected_terms]
    actual = [(coeff(term), var_name(term)) for term in linear_terms]
    # Sort both by name
    sort!(expected, by = x -> x[2])
    sort!(actual, by = x -> x[2])
    for ((exp_coeff, exp_var_name), (act_coeff, act_var_name)) in zip(expected, actual)
        @test isapprox(act_coeff, exp_coeff; atol=1e-9)
        @test act_var_name == exp_var_name
    end
end

@testset "linearize" begin
    @testset "Single Variable Tests" begin
        @testset "test_single_variable" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= X[0] 10.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [(1.0, "X[0]")])
            end
        end
        @testset "test_single_constant" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= 5.0 10.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 5.0, [])
            end
        end
        @testset "test_flat_addition" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (+ X[0] 5.0) 10.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 5.0, [(1.0, "X[0]")])
            end
        end
        @testset "test_variable_constant_subtraction" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (- X[0] 5.0) 0.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, -5.0, [(1.0, "X[0]")])
            end
        end
        @testset "test_constant_variable_subtraction" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (- 5.0 X[0]) 0.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 5.0, [(-1.0, "X[0]")])
            end
        end
        @testset "test_variable_constant_multiplication" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (* X[0] 3.5) 7.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [(3.5, "X[0]")])
            end
        end
        @testset "test_constant_variable_multiplication" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (* -2.0 X[0]) 0.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [(-2.0, "X[0]")])
            end
        end
        @testset "test_flat_negation" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (- X[0]) 0.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [(-1.0, "X[0]")])
            end
        end
        @testset "test_negative_coefficients" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (* -5.0 X[0]) 0.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [(-5.0, "X[0]")])
            end
        end
    end
    @testset "Multiple Variable Tests (Same and Different)" begin
        @testset "test_two_same_variables" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [2])
                (declare-output Y Real [1])
            )
            (assert (<= (+ X[0] 5.0 X[0]) 10.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 5.0, [(2.0, "X[0]")])
            end
        end
        @testset "test_variable_cancellation" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (- X[0] X[0]) 0.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [])
            end
        end
        @testset "test_two_different_variables" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [3])
                (declare-output Y Real [1])
            )
            (assert (<= (+ (- X[0] X[1]) 3.0) 0.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 3.0, [(1.0, "X[0]"), (-1.0, "X[1]")])
            end
        end
        @testset "test_three_different_variables" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [3])
                (declare-output Y Real [1])
            )
            (assert (<= (- X[0] X[1] X[2]) 0.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [(1.0, "X[0]"), (-1.0, "X[1]"), (-1.0, "X[2]")])
            end
        end
    end
    @testset "Complex Expressions" begin
        @testset "test_mixed_operations" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [2])
                (declare-output Y Real [1])
            )
            (assert (<= (+ 5.0 (* -1.0 X[0]) (- X[1])) 0.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 5.0, [(-1.0, "X[0]"), (-1.0, "X[1]")])
            end
        end
        @testset "test_nested_multiplication" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (+ (* 2.0 (* X[0] 3.0)) 2.0) 20.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 2.0, [(6.0, "X[0]")])
            end
        end
    end
    @testset "Zero Coefficient and Identity Tests" begin
        @testset "test_multiplication_by_zero" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (* X[0] 0.0) 0.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [])
            end
        end
        @testset "test_multiplication_by_one" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (* X[0] 1.0) 10.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [(1.0, "X[0]")])
            end
        end
        @testset "test_addition_with_zero" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (+ X[0] 0.0) 5.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [(1.0, "X[0]")])
            end
        end
    end
    @testset "Pure Constants Tests" begin
        @testset "test_constant_multiplication" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (* 2.0 3.0 2.5) 20.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 15.0, [])
            end
        end
        @testset "test_constant_addition" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (+ 1.0 2.0 5.0) 10.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 8.0, [])
            end
        end
    end
    @testset "Edge Cases" begin
        @testset "test_small_coefficients" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (* 0.0001 X[0]) 0.1))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [(0.0001, "X[0]")])
            end
        end
        @testset "test_large_coefficients" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network test
                (declare-input X Real [1])
                (declare-output Y Real [1])
            )
            (assert (<= (* 1000000.0 X[0]) 1000.0))
            """
            parse_query_str(content) do query
                left = get_lhs(query)
                lin_expr = linearize(left)
                check_linear_expr(lin_expr, 0.0, [(1000000.0, "X[0]")])
            end
        end
    end
    @testset "Non-linear Error Tests" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [2])
            (declare-output Y Real [1])
        )
        (assert (<= (* X[0] (+ X[1] 2.0)) 25.0))
        """
        parse_query_str(content) do query
            left = get_lhs(query)
            @test_throws ["Non-linear"] linearize(left)
        end
    end
end