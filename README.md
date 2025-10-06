# VNNLIB.jl
Julia parser for VNNLIB

**Work in progress!**

(first version that compiles)

## Current State

### Preparation

Make sure `CMake`, `git`, `BNFC`, `BISON` and `FLEX` are all available on your system.

### Usage

Julia should automatically build the C++ library the first time `VNNLIB.jl` is installed.

Afterwards, you should be able to run
```julia
pkg> activate .
julia> using VNNLIB
julia> ast = parse_query("path/to/.../acc.vnnlib")
#CxxWrap.CxxWrapCore.CxxPtr{TQuery}(Ptr{TQuery} @0x000000000991ae80)
julia> VNNLIB.children(ast)
#9-element CxxWrap.StdLib.StdVectorAllocated{CxxWrap.CxxWrapCore.ConstCxxPtr{VNNLIB.TNode}}:
# CxxWrap.CxxWrapCore.ConstCxxPtr{VNNLIB.TNode}(Ptr{VNNLIB.TNode} @0x000000000971ea80)
# CxxWrap.CxxWrapCore.ConstCxxPtr{VNNLIB.TNode}(Ptr{VNNLIB.TNode} @0x00000000097c1090)
# ...
# CxxWrap.CxxWrapCore.ConstCxxPtr{VNNLIB.TNode}(Ptr{VNNLIB.TNode} @0x00000000096c23f0)
julia> include("debug/walk.jl")
#TQuery: (vnnlib-version <2.0>) (declare-network acc (declare-input X Real [3]) (declare-output Y Real [])) (assert (<= (* -1.0 X [0]) 0.0)) (assert (<= X [0] 50.0)) (assert (<= (* -1.0 X [1]) 50.0)) (assert (<= X [1] 50.0)) (assert (<= (* -1.0 X [2]) 0.0)) (assert (<= X [2] 150.0)) (assert (<= (+ (* -1.5 X [1]) X [2]) -15.0)) (assert (or (<= Y [0] -3.0) (>= Y [0] 0.0))) 
# VNNLIB.TNode: (declare-network acc (declare-input X Real [3]) (declare-output Y Real [])) 
#  VNNLIB.TNode: (declare-input X Real [3]) 
#  VNNLIB.TNode: (declare-output Y Real []) 
# VNNLIB.TNode: (assert (<= (* -1.0 X [0]) 0.0)) 
#  VNNLIB.TNode: (<= (* -1.0 X [0]) 0.0) 
#   VNNLIB.TNode: (* -1.0 X [0]) 
#    VNNLIB.TNode: -1.0 
#    VNNLIB.TNode: X [0] 
#   VNNLIB.TNode: 0.0 
# ...
```
Note that Julia only knows that the child nodes are a subtype of `VNNLIB.TNode`!

## TODO

- [ ] Is there a way to make Julia know about the most specific subtypes of the child nodes?

