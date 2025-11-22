# Simple benchmarking script for VNNLib parsing performance.
# Usage: benchmark_parser.jl <vnnlib_file> [-n iterations]
using VNNLIB
using Dates
using BenchmarkTools

function noop(ast)
    return
end

function benchmark_parser(file::String, iterations::Int=10)
    content = read(file, String)
    println("Benchmarking VNNLib parser on file: $file")
    println("File size: $(sizeof(content)) bytes")
    println("Iterations: $iterations")
    println("Starting benchmark at $(Dates.now())")
    res = @benchmark parse_query_str($noop, $content) samples=iterations setup=(GC.gc())
    display(res)
    println("Benchmark completed at $(Dates.now())")
end

function run_benchmark(args)
    if length(args) < 1
        println("Usage: julia benchmark_parser.jl <vnnlib_file> [-n iterations]")
        exit(1)
    end
    file = args[1]
    iterations = 10
    for (i, arg) in enumerate(args)
        if arg == "-n" && i < length(args)
            iterations = parse(Int, args[i+1])
        end
    end
    benchmark_parser(file, iterations)
end

if abspath(PROGRAM_FILE) == @__FILE__
    run_benchmark(ARGS)
end