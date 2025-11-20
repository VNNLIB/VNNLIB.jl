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
julia> parse_query("path/to/.../acc.vnnlib") do (ast)
    println(ast)
    println(children(ast))
end
#(vnnlib-version <2.0>) (declare-network acc (declare-input X Real [3]) (declare-output Y Real [])) (assert (<= (* -1.0 X [0]) 0.0)) (assert (<= X [0] 50.0)) (assert (<= (* -1.0 X [1]) 50.0)) (assert (<= X [1] 50.0)) (assert (<= (* -1.0 X [2]) 0.0)) (assert (<= X [2] 150.0)) (assert (<= (+ (* -1.5 X [1]) X [2]) -15.0)) (assert (or (<= Y [0] -3.0) (>= Y [0] 0.0))) 
#CxxWrap.CxxWrapCore.ConstCxxPtr[(declare-network acc (declare-input X Real [3]) (declare-output Y Real [])) , (assert (<= (* -1.0 X [0]) 0.0)) , (assert (<= X [0] 50.0)) , (assert (<= (* -1.0 X [1]) 50.0)) , (assert (<= X [1] 50.0)) , (assert (<= (* -1.0 X [2]) 0.0)) , (assert (<= X [2] 150.0)) , (assert (<= (+ (* -1.5 X [1]) X [2]) -15.0)) , (assert (or (<= Y [0] -3.0) (>= Y [0] 0.0))) ]
julia> include("debug/walk.jl")
# VNNLIB.VNNLIBCore.TQuery: (vnnlib-version <2.0>) (declare-network acc (declare-input X Real [3]) (declare-output Y Real [])) (assert (<= (* -1.0 X [0]) 0.0)) (assert (<= X [0] 50.0)) (assert (<= (* -1.0 X [1]) 50.0)) (assert (<= X [1] 50.0)) (assert (<= (* -1.0 X [2]) 0.0)) (assert (<= X [2] 150.0)) (assert (<= (+ (* -1.5 X [1]) X [2]) -15.0)) (assert (or (<= Y [0] -3.0) (>= Y [0] 0.0))) 
#  VNNLIB.VNNLIBCore.TNetworkDefinition: (declare-network acc (declare-input X Real [3]) (declare-output Y Real [])) 
#   VNNLIB.VNNLIBCore.TInputDefinition: (declare-input X Real [3]) 
#   VNNLIB.VNNLIBCore.TOutputDefinition: (declare-output Y Real []) 
#  VNNLIB.VNNLIBCore.TAssertion: (assert (<= (* -1.0 X [0]) 0.0)) 
#   VNNLIB.VNNLIBCore.TLessEqual: (<= (* -1.0 X [0]) 0.0) 
#    VNNLIB.VNNLIBCore.TMultiply: (* -1.0 X [0]) 
#     VNNLIB.VNNLIBCore.TFloat: -1.0 
#     VNNLIB.VNNLIBCore.TVarExpr: X [0] 
#    VNNLIB.VNNLIBCore.TFloat: 0.0 
#  VNNLIB.VNNLIBCore.TAssertion: (assert (<= X [0] 50.0)) 
#   VNNLIB.VNNLIBCore.TLessEqual: (<= X [0] 50.0) 
# ...
```

## Contributing

### Exposing a C++ Type to Julia

To expose e.g. the `TNode` type (defined in `VNNLIB-CPP/include/TypedAbsyn.h`)
```c++
class VNNLIB_API TNode {
public:
	virtual ~TNode() = default;
	virtual void children(std::vector<const TNode*>& out) const = 0;
	virtual std::string toString() const = 0;

protected:
    // ...
}
```
we need to call `mod.add_type(...)` in the module definition in `src/VNNLib_julia.cpp`:
```c++
JLCXX_MODULE define_julia_module(jlcxx::Module& mod) {
    mod.add_type<TNode>("TNode");
}
```
In that case `<TNode>` references the C++ type and `"TNode"` the name of the type in Julia.

If we also want to expose e.g. its `to_string()` methods, we need to add the following:
```c++
JLCXX_MODULE define_julia_module(jlcxx::Module& mod) {
    mod.add_type<TNode>("TNode")
        .method("to_string", &TNode::toString);
}
```
Similarly to above, `"to_string"` will be the name of the method in Julia and `&TNode::toString` is the reference to the C++ function.

#### Inheritance

To give Julia information about class hierarchies, e.g. for `TElementType`
```c++
class VNNLIB_API TElementType : public TNode {
friend class TypedBuilder;
public:
	DType dtype{DType::Unknown};
	virtual ~TElementType() = default;
	void children(std::vector<const TNode*>& out) const override;
	std::string toString() const override;
protected:
	ElementType* src_ElementType{nullptr};
};
```
we need to add the type to `src/VNNLib_julia.cpp` as usual, but add information about its supertype while registering `TElementType` with Julia and in the namespace of `jlcxx`:
```c++
namespace jlcxx {
    template<> struct SuperType<TElementType> { typedef TNode type; };
}

JLCXX_MODULE define_julia_module(jlcxx::Module& mod) {
    mod.add_type<TNode>("TNode")
        .method("to_string", &TNode::toString);

    mod.add_type<TElementType>("TElementType", jlcxx::julia_base_type<TNode>());
}
```
We do not need to add the `toString()` method, because Julia knows that it is inherited from `TNode`.



