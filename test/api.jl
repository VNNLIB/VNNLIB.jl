@testset "API Tests" begin
    @testset "acc.vnnlib API Validation" begin
        content = """
        (vnnlib-version <2.0>)

        (declare-network acc
        	(declare-input X Real [3])
        	(declare-output Y Real [])
        )

        (assert (<= (* -1.0 X[0]) 0.0))
        (assert (<= X[0] 50.0))
        (assert (<= (* -1.0 X[1]) 50.0))
        (assert (<= X[1] 50.0))
        (assert (<= (* -1.0 X[2]) 0.0))
        (assert (<= X[2] 150.0))
        (assert (<= (+ (* -1.5 X[1]) X[2]) -15.0))

        (assert (or 
        	(<= Y -3.0)
        	(>= Y 0.0)
        ))
        """
        
        parse_query_str(content) do (ast)
            # Test TQuery level
            @test string(ast) == "(vnnlib-version <2.0>) (declare-network acc (declare-input X Real [3]) (declare-output Y Real [])) (assert (<= (* -1.0 X [0]) 0.0)) (assert (<= X [0] 50.0)) (assert (<= (* -1.0 X [1]) 50.0)) (assert (<= X [1] 50.0)) (assert (<= (* -1.0 X [2]) 0.0)) (assert (<= X [2] 150.0)) (assert (<= (+ (* -1.5 X [1]) X [2]) -15.0)) (assert (or (<= Y -3.0) (>= Y 0.0))) "
            
            children_list = VNNLIB.children(ast)
            @test length(children_list) == 9  # 1 network + 8 assertions
            
            networks = VNNLIB.networks(ast)
            @test length(networks) == 1
            
            assertions = VNNLIB.assertions(ast)
            @test length(assertions) == 8
            
            # Test network definition
            net = networks[1]
            @test string(net) == "(declare-network acc (declare-input X Real [3]) (declare-output Y Real [])) "
            @test VNNLIB.net_isometric_to(net) == ""
            @test VNNLIB.net_equal_to(net) == ""
            
            inputs = VNNLIB.net_inputs(net)
            @test length(inputs) == 1
            
            outputs = VNNLIB.net_outputs(net)
            @test length(outputs) == 1
            
            hidden = VNNLIB.net_hidden(net)
            @test length(hidden) == 0
            
            # Test input definition
            input_def = inputs[1]
            @test string(input_def) == "(declare-input X Real [3]) "
            @test VNNLIB.dtype(input_def) == VNNLIB.DReal
            @test VNNLIB.name(input_def) == "X"
            @test VNNLIB.onnx_name(input_def) == ""
            @test VNNLIB.shape(input_def) == [3]
            @test VNNLIB.kind(input_def) == VNNLIB.Input
            @test VNNLIB.network_name(input_def) == "acc"
            
            # Test output definition
            output_def = outputs[1]
            @test string(output_def) == "(declare-output Y Real []) "
            @test VNNLIB.dtype(output_def) == VNNLIB.DReal
            @test VNNLIB.name(output_def) == "Y"
            @test VNNLIB.onnx_name(output_def) == ""
            @test VNNLIB.shape(output_def) == Int64[]
            @test VNNLIB.kind(output_def) == VNNLIB.Output
            @test VNNLIB.network_name(output_def) == "acc"
            
            # Test first assertion: (assert (<= (* -1.0 X[0]) 0.0))
            assertion1 = assertions[1]
            @test string(assertion1) == "(assert (<= (* -1.0 X [0]) 0.0)) "
            expr1 = VNNLIB.expr(assertion1)
            @test string(expr1) == "(<= (* -1.0 X [0]) 0.0) "
            @test string(VNNLIB.lhs(expr1)) == "(* -1.0 X [0]) "
            @test string(VNNLIB.rhs(expr1)) == "0.0 "
            
            # Test second assertion: (assert (<= X[0] 50.0))
            assertion2 = assertions[2]
            @test string(assertion2) == "(assert (<= X [0] 50.0)) "
            expr2 = VNNLIB.expr(assertion2)
            @test string(expr2) == "(<= X [0] 50.0) "
            @test string(VNNLIB.lhs(expr2)) == "X [0] "
            @test string(VNNLIB.rhs(expr2)) == "50.0 "
            
            # Test third assertion: (assert (<= (* -1.0 X[1]) 50.0))
            assertion3 = assertions[3]
            @test string(assertion3) == "(assert (<= (* -1.0 X [1]) 50.0)) "
            expr3 = VNNLIB.expr(assertion3)
            @test string(expr3) == "(<= (* -1.0 X [1]) 50.0) "
            @test string(VNNLIB.lhs(expr3)) == "(* -1.0 X [1]) "
            @test string(VNNLIB.rhs(expr3)) == "50.0 "
            
            # Test fourth assertion: (assert (<= X[1] 50.0))
            assertion4 = assertions[4]
            @test string(assertion4) == "(assert (<= X [1] 50.0)) "
            expr4 = VNNLIB.expr(assertion4)
            @test string(expr4) == "(<= X [1] 50.0) "
            @test string(VNNLIB.lhs(expr4)) == "X [1] "
            @test string(VNNLIB.rhs(expr4)) == "50.0 "
            
            # Test fifth assertion: (assert (<= (* -1.0 X[2]) 0.0))
            assertion5 = assertions[5]
            @test string(assertion5) == "(assert (<= (* -1.0 X [2]) 0.0)) "
            expr5 = VNNLIB.expr(assertion5)
            @test string(expr5) == "(<= (* -1.0 X [2]) 0.0) "
            @test string(VNNLIB.lhs(expr5)) == "(* -1.0 X [2]) "
            @test string(VNNLIB.rhs(expr5)) == "0.0 "
            
            # Test sixth assertion: (assert (<= X[2] 150.0))
            assertion6 = assertions[6]
            @test string(assertion6) == "(assert (<= X [2] 150.0)) "
            expr6 = VNNLIB.expr(assertion6)
            @test string(expr6) == "(<= X [2] 150.0) "
            @test string(VNNLIB.lhs(expr6)) == "X [2] "
            @test string(VNNLIB.rhs(expr6)) == "150.0 "
            
            # Test seventh assertion: (assert (<= (+ (* -1.5 X[1]) X[2]) -15.0))
            assertion7 = assertions[7]
            @test string(assertion7) == "(assert (<= (+ (* -1.5 X [1]) X [2]) -15.0)) "
            expr7 = VNNLIB.expr(assertion7)
            @test string(expr7) == "(<= (+ (* -1.5 X [1]) X [2]) -15.0) "
            @test string(VNNLIB.lhs(expr7)) == "(+ (* -1.5 X [1]) X [2]) "
            @test string(VNNLIB.rhs(expr7)) == "-15.0 "
            
            # Test eighth assertion: (assert (or (<= Y -3.0) (>= Y 0.0)))
            assertion8 = assertions[8]
            @test string(assertion8) == "(assert (or (<= Y -3.0) (>= Y 0.0))) "
            expr8 = VNNLIB.expr(assertion8)
            @test string(expr8) == "(or (<= Y -3.0) (>= Y 0.0)) "
            
            # Test or expression args
            or_args = VNNLIB.args(expr8)
            @test length(or_args) == 2
            @test string(or_args[1]) == "(<= Y -3.0) "
            @test string(or_args[2]) == "(>= Y 0.0) "
        end
    end

    @testset "Arithmetic Operations and Negation" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [3])
            (declare-output Y Real [2])
        )
        (assert (<= (+ X[0] X[1]) 10.0))
        (assert (<= (- X[1] X[2]) 5.0))
        (assert (<= (* 2.0 X[0]) 20.0))
        (assert (<= (* -1.5 Y[0]) 3.0))
        """
        
        parse_query_str(content) do (ast)
            assertions = VNNLIB.assertions(ast)
            
            # Test TPlus: (+ X[0] X[1])
            plus_expr = VNNLIB.lhs(VNNLIB.expr(assertions[1]))
            @test string(plus_expr) == "(+ X [0] X [1]) "
            plus_args = VNNLIB.args(plus_expr)
            @test length(plus_args) == 2
            @test string(plus_args[1]) == "X [0] "
            @test string(plus_args[2]) == "X [1] "
            
            # Test TMinus: (- X[1] X[2])
            minus_expr = VNNLIB.lhs(VNNLIB.expr(assertions[2]))
            @test string(minus_expr) == "(- X [1] X [2]) "
            minus_args = VNNLIB.args(minus_expr)
            @test length(minus_args) == 2
            @test string(minus_args[1]) == "X [1] "
            @test string(minus_args[2]) == "X [2] "
            
            # Test TMultiply: (* 2.0 X[0])
            mult_expr = VNNLIB.lhs(VNNLIB.expr(assertions[3]))
            @test string(mult_expr) == "(* 2.0 X [0]) "
            mult_args = VNNLIB.args(mult_expr)
            @test length(mult_args) == 2
            @test string(mult_args[1]) == "2.0 "
            @test string(mult_args[2]) == "X [0] "
            
            # Test TNegate (implicit in negative coefficient): (* -1.5 Y[0])
            neg_mult_expr = VNNLIB.lhs(VNNLIB.expr(assertions[4]))
            @test string(neg_mult_expr) == "(* -1.5 Y [0]) "
            neg_mult_args = VNNLIB.args(neg_mult_expr)
            @test length(neg_mult_args) == 2
            @test string(neg_mult_args[1]) == "-1.5 "
            @test string(neg_mult_args[2]) == "Y [0] "
        end
    end

    @testset "Comparison Operators" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [2])
            (declare-output Y Real [2])
        )
        (assert (< X[0] 10.0))
        (assert (<= X[0] 20.0))
        (assert (> X[1] 5.0))
        (assert (>= X[1] 3.0))
        (assert (== Y[0] 0.0))
        (assert (!= Y[1] 1.0))
        """
        
        parse_query_str(content) do (ast)
            assertions = VNNLIB.assertions(ast)
            
            # Test TLessThan: (< X[0] 10.0)
            lt_expr = VNNLIB.expr(assertions[1])
            @test string(lt_expr) == "(< X [0] 10.0) "
            @test string(VNNLIB.lhs(lt_expr)) == "X [0] "
            @test string(VNNLIB.rhs(lt_expr)) == "10.0 "
            
            # Test TLessEqual: (<= X[0] 20.0)
            le_expr = VNNLIB.expr(assertions[2])
            @test string(le_expr) == "(<= X [0] 20.0) "
            @test string(VNNLIB.lhs(le_expr)) == "X [0] "
            @test string(VNNLIB.rhs(le_expr)) == "20.0 "
            
            # Test TGreaterThan: (> X[1] 5.0)
            gt_expr = VNNLIB.expr(assertions[3])
            @test string(gt_expr) == "(> X [1] 5.0) "
            @test string(VNNLIB.lhs(gt_expr)) == "X [1] "
            @test string(VNNLIB.rhs(gt_expr)) == "5.0 "
            
            # Test TGreaterEqual: (>= X[1] 3.0)
            ge_expr = VNNLIB.expr(assertions[4])
            @test string(ge_expr) == "(>= X [1] 3.0) "
            @test string(VNNLIB.lhs(ge_expr)) == "X [1] "
            @test string(VNNLIB.rhs(ge_expr)) == "3.0 "
            
            # Test TEqual: (== Y[0] 0.0)
            eq_expr = VNNLIB.expr(assertions[5])
            @test string(eq_expr) == "(== Y [0] 0.0) "
            @test string(VNNLIB.lhs(eq_expr)) == "Y [0] "
            @test string(VNNLIB.rhs(eq_expr)) == "0.0 "
            
            # Test TNotEqual: (!= Y[1] 1.0)
            neq_expr = VNNLIB.expr(assertions[6])
            @test string(neq_expr) == "(!= Y [1] 1.0) "
            @test string(VNNLIB.lhs(neq_expr)) == "Y [1] "
            @test string(VNNLIB.rhs(neq_expr)) == "1.0 "
        end
    end

    @testset "TAnd Connective" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [2])
            (declare-output Y Real [])
        )
        (assert (and (<= X[0] 10.0) (>= X[1] 5.0) (<= Y 3.0)))
        """
        
        parse_query_str(content) do (ast)
            assertions = VNNLIB.assertions(ast)
            and_expr = VNNLIB.expr(assertions[1])
            
            @test string(and_expr) == "(and (<= X [0] 10.0) (>= X [1] 5.0) (<= Y 3.0)) "
            
            and_args = VNNLIB.args(and_expr)
            @test length(and_args) == 3
            @test string(and_args[1]) == "(<= X [0] 10.0) "
            @test string(and_args[2]) == "(>= X [1] 5.0) "
            @test string(and_args[3]) == "(<= Y 3.0) "
        end
    end

    @testset "Hidden Variables" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [2])
            (declare-hidden H1 Real [3] "hidden_layer_1")
            (declare-hidden H2 Real [4] "hidden_layer_2")
            (declare-output Y Real [1])
        )
        (assert (<= X[0] 10.0))
        """
        
        parse_query_str(content) do (ast)
            networks = VNNLIB.networks(ast)
            net = networks[1]
            
            # Test hidden variables access
            hidden = VNNLIB.net_hidden(net)
            @test length(hidden) == 2
            
            # Test first hidden variable: H1 with ONNX name
            h1 = hidden[1]
            @test string(h1) == "(declare-hidden H1 Real [3] \"hidden_layer_1\") "
            @test VNNLIB.dtype(h1) == VNNLIB.DReal
            @test VNNLIB.name(h1) == "H1"
            @test VNNLIB.onnx_name(h1) == "hidden_layer_1"
            @test VNNLIB.shape(h1) == [3]
            @test VNNLIB.kind(h1) == VNNLIB.Hidden
            @test VNNLIB.network_name(h1) == "test"
            
            # Test second hidden variable: H2 without ONNX name
            h2 = hidden[2]
            @test string(h2) == "(declare-hidden H2 Real [4] \"hidden_layer_2\") "
            @test VNNLIB.dtype(h2) == VNNLIB.DReal
            @test VNNLIB.name(h2) == "H2"
            @test VNNLIB.onnx_name(h2) == "hidden_layer_2"
            @test VNNLIB.shape(h2) == [4]
            @test VNNLIB.kind(h2) == VNNLIB.Hidden
            @test VNNLIB.network_name(h2) == "test"
        end
    end

    @testset "Variable Expression Details" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [2, 3])
            (declare-output Y Real [])
        )
        (assert (<= X[1, 2] 10.0))
        (assert (>= Y 5.0))
        """
        
        parse_query_str(content) do (ast)
            assertions = VNNLIB.assertions(ast)
            
            # Test multidimensional variable with indices
            var_expr1 = VNNLIB.lhs(VNNLIB.expr(assertions[1]))
            @test string(var_expr1) == "X [1, 2] "
            @test VNNLIB.name(var_expr1) == "X"
            @test VNNLIB.onnx_name(var_expr1) == ""
            @test VNNLIB.shape(var_expr1) == [2, 3]
            @test VNNLIB.kind(var_expr1) == VNNLIB.Input
            @test VNNLIB.network_name(var_expr1) == "test"
            @test VNNLIB.indices(var_expr1) == [1, 2]
            @test VNNLIB.line(var_expr1) > 0  # Line number should be positive
            
            # Test single-dimensional variable with index
            var_expr2 = VNNLIB.lhs(VNNLIB.expr(assertions[2]))
            @test string(var_expr2) == "Y "
            @test VNNLIB.name(var_expr2) == "Y"
            @test VNNLIB.indices(var_expr2) == []
            @test VNNLIB.line(var_expr2) > 0
        end
    end

    @testset "Literal Details" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X Real [1])
            (declare-output Y Real [])
        )
        (assert (<= X[0] 42.5))
        (assert (>= Y -3.14159))
        """
        
        parse_query_str(content) do (ast)
            assertions = VNNLIB.assertions(ast)
            
            # Test float literal: 42.5
            float_lit1 = VNNLIB.rhs(VNNLIB.expr(assertions[1]))
            @test string(float_lit1) == "42.5 "
            @test VNNLIB.value(float_lit1) == 42.5
            @test VNNLIB.lexeme(float_lit1) == "42.5"
            @test VNNLIB.line(float_lit1) > 0
            
            # Test negative float literal: -3.14159
            float_lit2 = VNNLIB.rhs(VNNLIB.expr(assertions[2]))
            @test string(float_lit2) == "-3.14159 "
            @test VNNLIB.value(float_lit2) == -3.14159
            @test VNNLIB.lexeme(float_lit2) == "-3.14159"
            @test VNNLIB.line(float_lit2) > 0
        end
    end

    @testset "Integer Literals" begin
        content = """
        (vnnlib-version <2.0>)
        (declare-network test
            (declare-input X int32 [1])
            (declare-output Y int32 [])
        )
        (assert (<= X[0] 42))
        (assert (>= Y -100))
        """
        
        parse_query_str(content) do (ast)
            assertions = VNNLIB.assertions(ast)
            
            # Test integer literal: 42
            int_lit1 = VNNLIB.rhs(VNNLIB.expr(assertions[1]))
            @test string(int_lit1) == "42 "
            @test VNNLIB.value(int_lit1) == 42
            @test VNNLIB.lexeme(int_lit1) == "42"
            @test VNNLIB.line(int_lit1) > 0
            
            # Test negative integer literal: -100
            int_lit2 = VNNLIB.rhs(VNNLIB.expr(assertions[2]))
            @test string(int_lit2) == "-100 "
            @test VNNLIB.value(int_lit2) == -100
            @test VNNLIB.lexeme(int_lit2) == "-100"
            @test VNNLIB.line(int_lit2) > 0
        end
    end
end