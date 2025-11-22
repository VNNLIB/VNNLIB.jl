@testset "Compatibility Tests" begin
    # Helper function to assert box bounds match expected bounds (with inf handling)
    function assert_box_bounds(input_box, expected_bounds)
        @test length(input_box) == length(expected_bounds)
        
        for (i, ((actual_lower, actual_upper), (expected_lower, expected_upper))) in enumerate(zip(input_box, expected_bounds))
            # Handle infinite bounds
            if isinf(expected_lower)
                @test isinf(actual_lower) && actual_lower < 0
            else
                @test abs(actual_lower - expected_lower) < 1e-9
            end
            
            if isinf(expected_upper)
                @test isinf(actual_upper) && actual_upper > 0
            else
                @test abs(actual_upper - expected_upper) < 1e-9
            end
        end
    end

    # Helper function to assert polytope constraints match expected format
    function assert_polytope_constraints(polytope, expected_constraints)
        coeff_mat = VNNLIB.coeff_matrix(polytope)
        rhs_vec = VNNLIB.rhs(polytope)
        
        @test length(coeff_mat) == length(expected_constraints)
        @test length(rhs_vec) == length(expected_constraints)
        
        for (i, ((expected_coeffs, expected_rhs), actual_coeffs, actual_rhs)) in enumerate(zip(expected_constraints, coeff_mat, rhs_vec))
            @test length(actual_coeffs) == length(expected_coeffs)
            
            for (j, (actual_coeff, expected_coeff)) in enumerate(zip(actual_coeffs, expected_coeffs))
                @test abs(actual_coeff - expected_coeff) < 1e-9
            end
            
            @test abs(actual_rhs - expected_rhs) < 1e-9
        end
    end

    @testset "test_basic_input_output_constraints" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [2])
            (declare-output Y Real [1])
        )
        (assert (<= X[0] 1.0))
        (assert (>= X[0] 0.0))
        (assert (<= Y[0] 2.0))
        """
        
        parse_query_str(content) do (ast)
            cases = collect(VNNLIB.transform_to_compat(ast))
            @test length(cases) == 1
        end
    end

    @testset "test_single_output_disjunction" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [2])
            (declare-output Y Real [2])
        )
        (assert (<= X[0] 1.0))
        (assert (>= X[0] 0.0))
        (assert (or (<= Y[0] 2.0) (<= Y[1] 3.0)))
        """
        parse_query_str(content) do (ast)
            cases = collect(VNNLIB.transform_to_compat(ast))
            @test length(cases) == 1
            case = cases[1]

            # Check input bounds: X[0] ∈ [0, 1], X[1] ∈ [-inf, inf]
            assert_box_bounds(VNNLIB.input_box(case), [(0.0, 1.0), (-Inf, Inf)])
            
            # Check output constraints: 2 polytopes (one for each disjunct)
            output_constraints = VNNLIB.output_constraints(case)
            @test length(output_constraints) == 2
            
            # First polytope: Y[0] <= 2.0 (coeffs: [1, 0], rhs: 2.0)
            assert_polytope_constraints(output_constraints[1], [([1.0, 0.0], 2.0)])
            
            # Second polytope: Y[1] <= 3.0 (coeffs: [0, 1], rhs: 3.0)
            assert_polytope_constraints(output_constraints[2], [([0.0, 1.0], 3.0)])
        end
    end

    @testset "test_conjunction_of_output_constraints" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [1])
            (declare-output Y Real [2])
        )
        (assert (or (and (<= Y[0] 2.0) (<= Y[1] 3.0)) (<= Y[0] 1.0)))
        """
        parse_query_str(content) do (ast)
            cases = collect(VNNLIB.transform_to_compat(ast))
            @test length(cases) == 1
            case = cases[1]
            
            # Check input bounds: X[0] ∈ [-inf, inf]
            assert_box_bounds(VNNLIB.input_box(case), [(-Inf, Inf)])
            
            # Check output constraints: 2 polytopes
            output_constraints = VNNLIB.output_constraints(case)
            @test length(output_constraints) == 2
            
            # First polytope: (Y[0] <= 2.0) AND (Y[1] <= 3.0)
            assert_polytope_constraints(output_constraints[1], [
                ([1.0, 0.0], 2.0),  # Y[0] <= 2.0
                ([0.0, 1.0], 3.0)   # Y[1] <= 3.0
            ])
            
            # Second polytope: Y[0] <= 1.0
            assert_polytope_constraints(output_constraints[2], [([1.0, 0.0], 1.0)])
        end
    end

    @testset "test_complex_nested_disjunction" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [1])
            (declare-output Y Real [2])
        )
        (assert (or (and (<= Y[0] 1.0) (<= Y[1] 2.0)) 
                    (and (<= Y[0] 3.0) (<= Y[1] 4.0))))
        """
        parse_query_str(content) do (ast)
            cases = collect(VNNLIB.transform_to_compat(ast))
            @test length(cases) == 1
            case = cases[1]
            
            # Check output constraints: 2 polytopes
            output_constraints = VNNLIB.output_constraints(case)
            @test length(output_constraints) == 2
            
            # First polytope: (Y[0] <= 1.0) AND (Y[1] <= 2.0)
            assert_polytope_constraints(output_constraints[1], [
                ([1.0, 0.0], 1.0),  # Y[0] <= 1.0
                ([0.0, 1.0], 2.0)   # Y[1] <= 2.0
            ])
            
            # Second polytope: (Y[0] <= 3.0) AND (Y[1] <= 4.0)
            assert_polytope_constraints(output_constraints[2], [
                ([1.0, 0.0], 3.0),  # Y[0] <= 3.0
                ([0.0, 1.0], 4.0)   # Y[1] <= 4.0
            ])
        end
    end

    @testset "test_input_bounds_with_inequalities" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [3])
            (declare-output Y Real [1])
        )
        (assert (<= X[0] 5.0))
        (assert (>= X[0] -2.0))
        (assert (<= X[1] 10.0))
        (assert (>= X[2] 0.0))
        (assert (or (<= Y[0] 1.0)))
        """
        parse_query_str(content) do (ast)
            cases = collect(VNNLIB.transform_to_compat(ast))
            @test length(cases) == 1
            case = cases[1]
            
            # Check input bounds
            assert_box_bounds(VNNLIB.input_box(case), [
                (-2.0, 5.0),        # X[0]: [-2.0, 5.0]
                (-Inf, 10.0),       # X[1]: [-inf, 10.0]
                (0.0, Inf)          # X[2]: [0.0, inf]
            ])
        end
    end

    @testset "test_greater_equal_constraints" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [1])
            (declare-output Y Real [2])
        )
        (assert (or (>= Y[0] -1.0) (>= Y[1] -2.0)))
        """
        parse_query_str(content) do (ast)
            cases = collect(VNNLIB.transform_to_compat(ast))
            @test length(cases) == 1
            case = cases[1]

            output_constraints = VNNLIB.output_constraints(case)
            @test length(output_constraints) == 2

            # First polytope: Y[0] >= -1.0 → -Y[0] <= 1.0 (coeffs: [-1, 0], rhs: 1.0)
            assert_polytope_constraints(output_constraints[1], [([-1.0, 0.0], 1.0)])

            # Second polytope: Y[1] >= -2.0 → -Y[1] <= 2.0 (coeffs: [0, -1], rhs: 2.0)
            assert_polytope_constraints(output_constraints[2], [([0.0, -1.0], 2.0)])
        end
    end

    @testset "test_multiple_disjunctions" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [1])
            (declare-output Y Real [2])
        )
        (assert (or (<= Y[0] 1.0) (<= Y[1] 2.0)))
        (assert (or (<= Y[0] 3.0) (<= Y[1] 4.0)))
        """
        parse_query_str(content) do (ast)
            cases = collect(VNNLIB.transform_to_compat(ast))
            @test length(cases) == 1
            case = cases[1]

            # Should have 4 polytopes (cartesian product of the two disjunctions)
            # (Y[0] <= 1.0) ∧ (Y[0] <= 3.0), (Y[0] <= 1.0) ∧ (Y[1] <= 4.0), 
            # (Y[1] <= 2.0) ∧ (Y[0] <= 3.0), (Y[1] <= 2.0) ∧ (Y[1] <= 4.0)
            output_constraints = VNNLIB.output_constraints(case)
            @test length(output_constraints) == 4
        end
    end

    @testset "test_mult_network_error" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network net1
            (declare-input X Real [1])
            (declare-output Y Real [1])
        )
        (declare-network net2
            (declare-input Z Real [1])
            (declare-output W Real [1])
        )
        (assert (<= Y[0] 1.0))
        """
        @test_throws ["Only single-network queries are supported"] parse_query_str(content) do (ast)
            collect(VNNLIB.transform_to_compat(ast))
        end
    end

    @testset "test_multiple_input_variables_error" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [1])
            (declare-input Z Real [1])
            (declare-output Y Real [1])
        )
        (assert (<= Y[0] 1.0))
        """
        @test_throws ["Multiple input variables found"] parse_query_str(content) do (ast)
            collect(VNNLIB.transform_to_compat(ast))
        end
    end

    @testset "test_multiple_output_variables_error" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [1])
            (declare-output Y Real [1])
            (declare-output Z Real [1])
        )
        (assert (<= Y[0] 1.0))
        """
        @test_throws ["Multiple output variables found"] parse_query_str(content) do (ast)
            collect(VNNLIB.transform_to_compat(ast))
        end
    end

    @testset "test_multi_dimensional_input" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [4])
            (declare-output Y Real [1])
        )
        (assert (<= X[0] 1.0))
        (assert (>= X[3] -1.0))
        (assert (or (<= Y[0] 2.0)))
        """
        parse_query_str(content) do (ast)
            cases = collect(VNNLIB.transform_to_compat(ast))
            @test length(cases) == 1
            case = cases[1]
            
            # Should have 4 dimensions for the input
            input_box = VNNLIB.input_box(case)
            @test length(input_box) == 4
            
            # X[0] <= 1.0 affects index 0, X[3] >= -1.0 affects index 3
            expected_bounds = [
                (-Inf, 1.0),        # X[0]
                (-Inf, Inf),        # X[1]
                (-Inf, Inf),        # X[2]
                (-1.0, Inf)         # X[3]
            ]
            assert_box_bounds(input_box, expected_bounds)
        end
    end

    @testset "test_arithmetic_expressions_in_constraints" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [2])
            (declare-output Y Real [2])
        )
        (assert (<= (* 2.0 X[0]) 10.0))
        (assert (or (<= (* 2.0 Y[0]) 6.0) (<= (+ Y[0] Y[1]) 9.0)))
        """
        parse_query_str(content) do (ast)
            cases = collect(VNNLIB.transform_to_compat(ast))
            @test length(cases) == 1
            case = cases[1]
            
            # Input constraint: 2.0*X[0] <= 10.0 should bound X[0] to (-inf, 5.0]
            expected_bounds = [
                (-Inf, 5.0),        # X[0]: 2.0*X[0] <= 10.0 => X[0] <= 5.0
                (-Inf, Inf)         # X[1]: unbounded
            ]
            assert_box_bounds(VNNLIB.input_box(case), expected_bounds)
            
            # Output constraints: disjunction with arithmetic expressions
            output_constraints = VNNLIB.output_constraints(case)
            @test length(output_constraints) == 2
            
            # First polytope: 2*Y[0] <= 6.0 (coeffs: [2, 0], rhs: 6.0)
            assert_polytope_constraints(output_constraints[1], [([2.0, 0.0], 6.0)])
            
            # Second polytope: Y[0] + Y[1] <= 9.0 (coeffs: [1, 1], rhs: 9.0)
            assert_polytope_constraints(output_constraints[2], [([1.0, 1.0], 9.0)])
        end
    end

    @testset "test_edge_case_single_constraint_disjunction" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [1])
            (declare-output Y Real [1])
        )
        (assert (or (<= Y[0] 5.0)))
        """
        
        parse_query_str(content) do (ast)
            cases = collect(VNNLIB.transform_to_compat(ast))
            @test length(cases) == 1
            case = cases[1]
            
            output_constraints = VNNLIB.output_constraints(case)
            @test length(output_constraints) == 1
            assert_polytope_constraints(output_constraints[1], [([1.0], 5.0)])
        end
    end

    @testset "test_mixed_input_output_constraints_error" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [1])
            (declare-output Y Real [1])
        )
        (assert (or (<= (+ X[0] Y[0]) 5.0)))
        """
        
        # Mixed input-output constraints should be rejected
        @test_throws ["Input-output mixed constraints are not supported"] parse_query_str(content) do (ast)
            collect(VNNLIB.transform_to_compat(ast))
        end
    end

    @testset "test_large_disjunction" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [1])
            (declare-output Y Real [3])
        )
        (assert (or (<= Y[0] 1.0) (<= Y[1] 2.0) (<= Y[2] 3.0) (>= Y[0] -1.0)))
        """
        
        parse_query_str(content) do (ast)
            cases = collect(VNNLIB.transform_to_compat(ast))
            @test length(cases) == 1
            case = cases[1]
            
            # Should have 4 polytopes (one for each disjunct)
            output_constraints = VNNLIB.output_constraints(case)
            @test length(output_constraints) == 4
            
            # Check each polytope
            assert_polytope_constraints(output_constraints[1], [([1.0, 0.0, 0.0], 1.0)])   # Y[0] <= 1.0
            assert_polytope_constraints(output_constraints[2], [([0.0, 1.0, 0.0], 2.0)])   # Y[1] <= 2.0
            assert_polytope_constraints(output_constraints[3], [([0.0, 0.0, 1.0], 3.0)])   # Y[2] <= 3.0
            assert_polytope_constraints(output_constraints[4], [([-1.0, 0.0, 0.0], 1.0)])  # Y[0] >= -1.0
        end
    end
end