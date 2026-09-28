const TEST_SOLVER = ENV["VNNLIB_TEST_SOLVER"]

function write_solver_query(dir)
    query = joinpath(dir, "query.vnnlib")

    write(query, """
(vnnlib-version <2.0>)
(declare-network f
    (declare-input X float32 [1])
    (declare-output Y float32 [1])
)
(assert (<= X[0] 1.0))
""")

    return query
end


@testset "Solver Tests" begin
    @testset "verify results" begin
        expected_results = [
            ("sat", SolverSat),
            ("unsat", SolverUnsat),
            ("unknown", SolverUnknown),
            ("timed-out", SolverTimedOut),
        ]

        for (result_name, expected) in expected_results
            mktempdir() do dir
                query = write_solver_query(dir)
                config = joinpath(dir, "solver.toml")

                write(config, """
[solver]
name = "Test Solver"
version = "0.1.0"

[[rules]]
match = "*"
result = "$result_name"
""")

                withenv("VNNLIB_TEST_SOLVER_CONFIG" => config) do
                    solver = Solver(TEST_SOLVER)

                    @test verify(
                        solver,
                        query,
                        Dict{String,String}()
                    ) == expected
                end
            end
        end
    end


    @testset "verify timeout" begin
        mktempdir() do dir
            query = write_solver_query(dir)
            config = joinpath(dir, "solver.toml")

            write(config, """
[solver]
name = "Test Solver"
version = "0.1.0"

[[rules]]
match = "*"
result = "sat"
delay_seconds = 2
""")

            withenv("VNNLIB_TEST_SOLVER_CONFIG" => config) do
                solver = Solver(TEST_SOLVER)

                @test verify(
                    solver,
                    query,
                    Dict{String,String}(),
                    1
                ) == SolverTimedOut
            end
        end
    end


    @testset "verify networks" begin
        mktempdir() do dir
            query = write_solver_query(dir)
            model = joinpath(dir, "model.onnx")
            config = joinpath(dir, "solver.toml")

            write(model, "")

            write(config, """
[solver]
name = "Test Solver"
version = "0.1.0"

[[rules]]
match = "*"
result = "sat"

[rules.model_element_types]
X = "float32"
""")

            withenv("VNNLIB_TEST_SOLVER_CONFIG" => config) do
                solver = Solver(TEST_SOLVER)

                @test verify(
                    solver,
                    query,
                    Dict("f" => model)
                ) == SolverSat
            end
        end
    end


    @testset "verify errors" begin
        mktempdir() do dir
            query = write_solver_query(dir)

            solver = Solver("definitely-not-a-real-vnnlib-solver")
            @test_throws ErrorException verify(
                solver,
                query,
                Dict{String,String}()
            )
        end

        error_cases = [
            ("non-zero exit", "exit_code = 7"),
            ("malformed output", "raw_stdout = \"invalid\""),
            ("abnormal termination", "crash = true"),
        ]

        for (name, setting) in error_cases
            @testset "$name" begin
                mktempdir() do dir
                    query = write_solver_query(dir)
                    config = joinpath(dir, "solver.toml")

                    write(config, """
[solver]
name = "Test Solver"
version = "0.1.0"

[[rules]]
match = "*"
result = "sat"
$setting
""")

                    withenv("VNNLIB_TEST_SOLVER_CONFIG" => config) do
                        solver = Solver(TEST_SOLVER)

                        @test_throws ErrorException verify(
                            solver,
                            query,
                            Dict{String,String}()
                        )
                    end
                end
            end
        end
    end


    @testset "supports" begin
        mktempdir() do dir
            config = joinpath(dir, "supports.toml")

            write(config, """
[solver]
name = "Test Solver"
version = "0.1.0"

[capabilities]
onnx-opset-versions = ["13", "21"]
onnx-element-types = ["real", "float32", "float64", "int32"]
vnnlib-versions = ["2.0", "2.0"]
hidden-node-theories = ["NH"]
multiple-input-output-theories = ["SIO"]
multiple-network-theories = ["SNET"]
multiple-node-comparison-theories = ["SNC"]
arithmetic-complexity-theories = ["BND", "LIN"]
optimised-disjunctive-reasoning = false
serialise-assignments = false

[[capabilities.onnx-operators]]
name = "Gemm"
element-types = ["float32", "float64"]

[[capabilities.onnx-operators]]
name = "Relu"

[soundness]
sound-for = ["real", "float32", "float64", "int32"]
""")

            withenv("VNNLIB_TEST_SOLVER_CONFIG" => config) do
                solver = Solver(TEST_SOLVER)

                opset = supports_onnx_opset_versions(solver)
                @test minimum_opset(opset) == 13
                @test maximum_opset(opset) == 21

                @test collect(supports_onnx_element_types(solver)) ==
                    [VNNLIB.DReal, VNNLIB.DF32, VNNLIB.DF64, VNNLIB.DI32]

                operators = collect(supports_onnx_operators(solver))
                @test length(operators) == 2
                @test operator_name(operators[1]) == "Gemm"
                @test collect(element_types(operators[1])) == [VNNLIB.DF32, VNNLIB.DF64]
                @test operator_name(operators[2]) == "Relu"
                @test isempty(collect(element_types(operators[2])))

                versions = supports_vnnlib_versions(solver)
                minimum = minimum_version(versions)
                maximum = maximum_version(versions)

                @test major(minimum) == 2
                @test minor(minimum) == 0
                @test patch(minimum) === nothing
                @test extra(minimum) == ""

                @test major(maximum) == 2
                @test minor(maximum) == 0
                @test patch(maximum) === nothing
                @test extra(maximum) == ""

                @test collect(supports_hidden_node_theories(solver)) ==
                    [HiddenNH]

                @test collect(supports_multiple_input_output_theories(solver)) ==
                    [InputOutputSIO]

                @test collect(supports_multiple_network_theories(solver)) ==
                    [NetworkSNET]

                @test collect(supports_multiple_node_comparison_theories(solver)) ==
                    [NodeComparisonSNC]

                @test collect(supports_arithmetic_complexity_theories(solver)) ==
                    [ArithmeticBND, ArithmeticLIN]

                @test supports_optimised_disjunctive_reasoning(solver) == false
                @test supports_serialise_assignments(solver) == false
            end
        end
    end
end
