using Test

using VNNLIB
using CxxWrap

include("util.jl")

include("typecheck.jl")
include("scopecheck.jl")
include("linearize.jl")
include("dnf.jl")
include("congruence.jl")
include("compat.jl")
include("api.jl")