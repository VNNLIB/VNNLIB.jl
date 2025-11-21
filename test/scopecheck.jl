@testset "Scope Check" begin
    @testset "Duplicate Declaration Tests" begin
        invalid_content = """
        (vnnlib-version <2.0>)
        (declare-network acc
            (declare-input X Real [3])
            (declare-input X Real [3]) ; Duplicate
            (declare-output Y Real [1])
        )
        (assert (or 
            (<= Y[0] -3.0)
            (>= Y[0] 0.0)
        ))
        """
        @test_throws ["\"error_count\": 1", "MultipleDeclaration", "X"] parse_query_str(noop, invalid_content)
    end
    @testset "Undeclared Variable Tests" begin
        invalid_content = """
        (vnnlib-version <2.0>)
        (declare-network acc
            (declare-input X Real [3])
            (declare-output Y Real [1])
        )
        (assert (or 
            (<= Z[0] -3.0) ; Z is undeclared
            (>= Y[0] 0.0)
        ))
        """
        @test_throws ["\"error_count\": 1", "UndeclaredVariable", "Z"] parse_query_str(noop, invalid_content)
    end
    @testset "Invalid Dimensions Tests" begin
        invalid_content = """
        (vnnlib-version <2.0>)
        (declare-network acc
            (declare-input X Real [0, 0])   ; invalid dimensions
            (declare-output Y Real [])
        )
        (assert (or 
            (<= X[10, 10] -3.0) ; out of bounds access
            (>= Y[0] 0.0)
        ))
        """
        @test_throws ["\"error_count\": 2", "InvalidDimensions", "X", "UndeclaredVariable", "X"] parse_query_str(noop, invalid_content)
    end
    @testset "Index Bounds Tests" begin
        @testset "test_out_of_bounds_indices" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X Real [3, 4])   ; X is a 3x4 matrix
                (declare-output Y Real [])
            )
            (assert (or 
                (<= X[4, 4] -3.0) ; out of bounds access
                (>= Y[0] 0.0)
            ))
            """
            @test_throws ["\"error_count\": 1", "IndexOutOfBounds", "X[4,4]", "Index 4 is out of bounds"] parse_query_str(noop, invalid_content)
        end
        @testset "test_too_many_indices" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X Real [3, 4])   ; X is a 3x4 matrix
                (declare-output Y Real [])
            )
            (assert (or 
                (<= X[1, 2, 3] -3.0) ; too many indices
                (>= Y[0] 0.0)
            ))
            """
            @test_throws ["\"error_count\": 1", "TooManyIndices", "X[1,2,3]"] parse_query_str(noop, invalid_content)
        end
        @testset "test_not_enough_indices" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X Real [3, 4])   ; X is a 3x4 matrix
                (declare-output Y Real [])
            )
            (assert (or 
                (<= X[1] -3.0) ; not enough indices
                (>= Y[0] 0.0)
            ))
            """
            @test_throws ["\"error_count\": 1", "NotEnoughIndices", "X[1]"] parse_query_str(noop, invalid_content)
        end
    end
    @testset "ONNX Name Consistency Tests" begin
        @testset "1 inconsistent" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X Real [] "x_in")          
                (declare-input Z Real [])                 
                (declare-output Y Real [] "y_out")          
            )
            (assert (>= Y[0] 0.0))
            """
            @test_throws ["\"error_count\": 1", "UnexpectedOnnxName"] parse_query_str(noop, invalid_content)
        end
        @testset "2 inconsistent" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X Real [])                  
                (declare-input Z Real [] "z_in")           
                (declare-output Y Real [] "y_out")         
            )
            (assert (>= Y[0] 0.0))
            """
            @test_throws ["\"error_count\": 2", "UnexpectedOnnxName"] parse_query_str(noop, invalid_content)
        end
        @testset "Mixed ONNX Names" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X Real [] "x_in")           
                (declare-input Z Real [] "z_in")           
                (declare-output Y Real [])                 
            )
            (assert (>= Y[0] 0.0))
            """
            @test_throws ["\"error_count\": 1", "UnexpectedOnnxName"] parse_query_str(noop, invalid_content)
        end
        @testset "Multiple Mixed ONNX Names" begin
            invalid_content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X Real [])           
                (declare-input Z Real [] "z_in")       
                (declare-output Y Real [] "y_out")                
            )
            (assert (>= Y[0] 0.0))
            """
            @test_throws ["\"error_count\": 2", "UnexpectedOnnxName"] parse_query_str(noop, invalid_content)
        end
        @testset "test_consistent_onnx_names_all_named" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X Real [] "x_in")          
                (declare-input Z Real [] "z_in")          
                (declare-output Y Real [] "y_out")          
            )
            (assert (>= Y[0] 0.0))
            """
            passed = false
            parse_query_str(content) do _
                passed = true
            end
            @test passed
        end
        @testset "test_consistent_onnx_names_none_named" begin
            content = """
            (vnnlib-version <2.0>)
            (declare-network acc
                (declare-input X Real [])           
                (declare-input Z Real [])          
                (declare-output Y Real [])          
            )
            (assert (>= Y[0] 0.0))
            """
            passed = false
            parse_query_str(content) do _
                passed = true
            end
            @test passed
        end
    end
end