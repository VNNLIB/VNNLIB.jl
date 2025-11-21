using Test

using VNNLIB


function noop(x...)
end

@testset "Type Checking" begin

    @testset "Single Error Tests" begin

        @testset "test_float_variable_with_int_constant" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X float16 [1])
                (declare-output Y float16 [1])
            )
            (assert (<= Y[0] 5))
            """
            @test_throws ["\"error_count\": 1", "TypeMismatch", "5"] parse_query_str(noop, invalid_content)
        end

        @testset "test_int_variable_with_float_constant" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X int32 [1])
                (declare-output Y int32 [1])
            )
            (assert (<= Y[0] 3.14))
            """
            @test_throws ["\"error_count\": 1", "TypeMismatch", "3.14"] parse_query_str(noop, invalid_content)
        end

        @testset "test_uint_variable_with_negative_constant" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X uint32 [1])
                (declare-output Y uint32 [1])
            )
            (assert (<= Y[0] -5))
            """
            @test_throws ["\"error_count\": 1", "TypeMismatch", "-5"] parse_query_str(noop, invalid_content)
        end

        @testset "test_mixed_variable_types" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X float16 [1])
                (declare-hidden Z int32 [1] "z_in")
                (declare-output Y float16 [1])
            )
            (assert (<= X[0] Z[0]))
            """
            @test_throws ["\"error_count\": 1", "TypeMismatch", "Z"] parse_query_str(noop, invalid_content)
        end

        @testset "test_mixed_variable_precision" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X float16 [1])
                (declare-hidden Z float32 [1] "z_in")
                (declare-output Y float16 [1])
            )
            (assert (<= X[0] Z[0]))
            """
            @test_throws ["\"error_count\": 1", "TypeMismatch", "Z"] parse_query_str(noop, invalid_content)
        end

        @testset "test_mixed_constant_types" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X int8 [1])
                (declare-output Y int8 [1])
            )
            (assert (<= X[0] (+ 3 3.0)))
            """
            @test_throws ["\"error_count\": 1", "TypeMismatch", "3.0"] parse_query_str(noop, invalid_content)
        end
    end

    @testset "Multiple Error Tests" begin

        @testset "test_multiple_operand_mismatches" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X int8 [1])
                (declare-input Z int16 [1])
                (declare-output Y int32 [1])
            )
            (assert (<= 0 (+ X[0] Z[0] 3.14)))
            """
            @test_throws ["\"error_count\": 2", "TypeMismatch", "Z", "3.14"] parse_query_str(noop, invalid_content)
        end

        @testset "test_multiple_assertions_mismatches" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X int8 [1])
                (declare-input Z int16 [1])
                (declare-output Y int32 [1])
            )
            (assert (<= 0.0 X[0]))
            (assert (<= 0.0 Z[0]))
            (assert (<= 0.0 Y[0]))
            """
            @test_throws ["\"error_count\": 3", "TypeMismatch", "X", "Z", "Y"] parse_query_str(noop, invalid_content)
        end
    end

    @testset "Valid Type Combinations Tests (no errors expected)" begin

        @testset "test_mismatches_in_connective" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X int8 [1])
                (declare-input Z int16 [1])
                (declare-output Y int32 [1])
            )
            (assert (and (<= 0 X[0]) (<= 0 Z[0]) (<= 0 Y[0])))
            """
            passed = false
            parse_query_str(invalid_content) do (ast)
                passed = true
            end # should not throw
            @test passed
        end

        @testset "test_same_type_variables" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X float32 [1])
                (declare-input Z float32 [1])
                (declare-output Y float32 [1])
            )
            (assert (<= (+ X[0] Z[0]) Y[0]))
            """
            passed = false
            parse_query_str(content) do (ast)
                passed = true
            end # should not throw
            @test passed
        end

        @testset "test_same_precision_integers" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X int32 [1])
                (declare-input Z int32 [1])
                (declare-output Y int32 [1])
            )
            (assert (<= (+ X[0] Z[0] 42) Y[0]))
            """
            passed = false
            parse_query_str(content) do (ast)
                passed = true
            end # should not throw
            @test passed
        end

        @testset "test_float_with_float_constant" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X float32 [1])
                (declare-output Y float32 [1])
            )
            (assert (<= (+ X[0] 3.14) Y[0]))
            """
            passed = false
            parse_query_str(content) do (ast)
                passed = true
            end # should not throw
            @test passed
        end
        @testset "test_int_with_int_constant" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X int16 [1])
                (declare-output Y int16 [1])
            )
            (assert (<= (+ X[0] 42) Y[0]))
            """
            passed = false
            parse_query_str(content) do (ast)
                passed = true
            end # should not throw
            @test passed
        end



    end

end
