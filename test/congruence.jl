@testset "Congruence Tests" begin
    @testset "Passing" begin
        @testset "test_valid_equal_to_basic" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network net1
                (declare-input X1 Real [2])
                (declare-output Y1 Real [1])
            )
            (declare-network net2
                (equal-to net1)
                (declare-input X2 Real [2])
                (declare-output Y2 Real [1])
            )
            (assert (>= X1[0] 0.0))
            """
            passes = false
            parse_query_str(content) do (ast)
                passes = true
            end
            @test passes
        end
        @testset "test_valid_isomorphic_to_basic" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network net1
                (declare-input X1 Real [3])
                (declare-output Y1 Real [2])
            )
            (declare-network net2
                (isomorphic-to net1)
                (declare-input X2 Real [3])
                (declare-output Y2 Real [2])
            )
            (assert (>= X1[0] 0.0))
            """
            passes = false
            parse_query_str(content) do (ast)
                passes = true
            end
            @test passes
        end
        @testset "test_valid_onnx_congruence" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network net1
                (declare-input X1 Real [2] "input_tensor")
                (declare-output Y1 Real [1] "output_tensor")
            )
            (declare-network net2
                (equal-to net1)
                (declare-input X2 Real [2] "input_tensor")
                (declare-output Y2 Real [1] "output_tensor")
            )
            (assert (>= X1[0] 0.0))
            """
            passes = false
            parse_query_str(content) do (ast)
                passes = true
            end
            @test passes
        end
    end
    @testset "Mismatches" begin
        @testset "test_shape_mismatch" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network net1
                (declare-input X1 Real [2, 3])
                (declare-output Y1 Real [1])
            )
            (declare-network net2
                (equal-to net1)
                (declare-input X2 Real [3, 4])
                (declare-output Y2 Real [1])
            )
            (assert (>= X1[0, 0] 0.0))
            """
            @test_throws ["\"error_count\": 1", "Shape mismatch", "net1"] parse_query_str(noop, invalid_content)
        end
        @testset "test_variable_count_mismatch" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network net1
                (declare-input X1 Real [2])
                (declare-output Y1 Real [1])
            )
            (declare-network net2
                (equal-to net1)
                (declare-input X2 Real [2])
                (declare-input X3 Real [2])
                (declare-output Y2 Real [1])
            )
            (assert (>= X1[0] 0.0))
            """
            @test_throws ["\"error_count\": 1", "Number of variables mismatch", "net1"] parse_query_str(noop, invalid_content)
        end
        @testset "test_onnx_name_mismatches" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network net1
                (declare-input X1 Real [2] "input_tensor")
                (declare-output Y1 Real [1] "output_tensor")
            )
            (declare-network net2
                (equal-to net1)
                (declare-input X2 Real [2] "different_input")
                (declare-output Y2 Real [1] "output_tensor")
            )
            (assert (>= X1[0] 0.0))
            """
            @test_throws ["\"error_count\": 1", "ONNX name 'different_input' not found", "net1"] parse_query_str(noop, invalid_content)
        end
        @testset "test_type_mismatches" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network net1
                (declare-input X1 Real [2])
                (declare-output Y1 Real [1])
            )
            (declare-network net2
                (equal-to net1)
                (declare-input X2 int32 [2])
                (declare-output Y2 Real [1])
            )
            (assert (>= X1[0] 0.0))
            """
            @test_throws ["\"error_count\": 1", "TypeMismatch", "net1"] parse_query_str(noop, invalid_content)
        end
        @testset "test_onnx_naming_convention_mismatch" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network net1
                (declare-input X1 Real [2] "input_tensor")
                (declare-output Y1 Real [1] "output_tensor")
            )
            (declare-network net2
                (equal-to net1)
                (declare-input X2 Real [2])  ; Using ordered variables instead of named variables
                (declare-output Y2 Real [1])
            )
            (assert (>= X1[0] 0.0))
            """
            @test_throws ["\"error_count\": 1", "Variable naming convention mismatch", "net1"] parse_query_str(noop, invalid_content)
        end
    end
    @testset "Network Reference Errors" begin
        @testset "test_missing_referenced_network" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network net1
                (equal-to nonexistent)
                (declare-input X1 Real [2])
                (declare-output Y1 Real [1])
            )
            (assert (>= X1[0] 0.0))
            """
            @test_throws ["\"error_count\": 1", "Referenced network 'nonexistent' not found"] parse_query_str(noop, invalid_content)
        end
        @testset "test_forward_network_ref" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network net1
                (equal-to net2)
                (declare-input X1 Real [2])
                (declare-output Y1 Real [1])
            )
            (declare-network net2
                (declare-input X2 Real [2])
                (declare-output Y2 Real [1])
            )
            (assert (>= X1[0] 0.0))
            """
            @test_throws ["\"error_count\": 1", "Referenced network 'net2' not found"] parse_query_str(noop, invalid_content)
        end
    end
    @testset "Multiple Network Chain Test" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network net1
            (declare-input X1 Real [2])
            (declare-output Y1 Real [1])
        )
        (declare-network net2
            (equal-to net1)
            (declare-input X2 Real [2])
            (declare-output Y2 Real [1])
        )
        (declare-network net3
            (equal-to net2)
            (declare-input X3 Real [2])
            (declare-output Y3 Real [1])
        )
        
        (assert (>= X1[0] 0.0))
        """
        passes = false
        parse_query_str(content) do (ast)
            passes = true
        end
        @test passes
    end
end