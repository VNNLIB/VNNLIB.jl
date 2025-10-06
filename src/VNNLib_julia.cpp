// C++ wrapper for VNNLib using CxxWrap
#include <jlcxx/jlcxx.hpp>
#include <jlcxx/stl.hpp>
#include <vector>
#include "../deps/VNNLib/include/VNNLib.h"
#include "../deps/VNNLib/include/TypedAbsyn.h"

// parse_query: returns string representation of parsed query
//std::string jl_parse_query(const std::string& path) {
//    auto query_ptr = parse_query(path);
//    if (!query_ptr) return "";
//    return query_ptr->toString();
//}

TQuery* jl_parse_query(const std::string& path) {
    return parse_query(path).release();
}

// parse_query_str: returns string representation of parsed query from string
std::string jl_parse_query_str(const std::string& content) {
    auto query_ptr = parse_query_str(content);
    if (!query_ptr) return "";
    return query_ptr->toString();
}

// check_query: returns result string
std::string jl_check_query(const std::string& content) {
    return check_query(content);
}

// check_query_str: returns result string
std::string jl_check_query_str(const std::string& content) {
    return check_query_str(content);
}

// for TNode references
std::vector<const TNode*> jl_children(const TNode& node) {
    std::vector<const TNode*> out;
    node.children(out);
    return out;
}

// for TNode pointers
std::vector<const TNode*> jl_children_ptr(const TNode* node) {
    if (!node) return {};
    return jl_children(*node);
}


// Register super types for inheritance
namespace jlcxx {
    template<> struct SuperType<TElementType> { typedef TNode type; };

    template<> struct SuperType<TArithExpr> { typedef TNode type; };
    template<> struct SuperType<TVarExpr> { typedef TArithExpr type; };
    template<> struct SuperType<TLiteral> { typedef TArithExpr type; };
    template<> struct SuperType<TNegate> { typedef TArithExpr type; };
    template<> struct SuperType<TPlus> { typedef TArithExpr type; };
    template<> struct SuperType<TMinus> { typedef TArithExpr type; };
    template<> struct SuperType<TMultiply> { typedef TArithExpr type; };

    template<> struct SuperType<TBoolExpr> { typedef TNode type; };
    template<> struct SuperType<TCompare> { typedef TBoolExpr type; };
    template<> struct SuperType<TConnective> { typedef TBoolExpr type; };

    template<> struct SuperType<TAssertion> { typedef TNode type; };
    template<> struct SuperType<TInputDefinition> { typedef TNode type; };
    template<> struct SuperType<THiddenDefinition> { typedef TNode type; };
    template<> struct SuperType<TOutputDefinition> { typedef TNode type; };
    template<> struct SuperType<TNetworkDefinition> { typedef TNode type; };
    template<> struct SuperType<TVersion> { typedef TNode type; };
    template<> struct SuperType<TQuery> { typedef TNode type; };
}

JLCXX_MODULE define_julia_module(jlcxx::Module& mod) {

    // Register all types and methods from TypedAbsyn.cpp
    mod.add_type<TNode>("TNode")
        .method("children", [](const TNode& n) {
            return jl_children(n);
        })
        .method("children", [](const TNode* n) {
            return jl_children_ptr(n);
        })
        .method("to_string", &TNode::toString);

    mod.add_type<TElementType>("TElementType", jlcxx::julia_base_type<TNode>())
        .method("to_string", &TElementType::toString);

    mod.add_type<TArithExpr>("TArithExpr", jlcxx::julia_base_type<TNode>())
        .method("to_string", &TArithExpr::toString);

    mod.add_type<TVarExpr>("TVarExpr", jlcxx::julia_base_type<TArithExpr>());
    mod.add_type<TLiteral>("TLiteral", jlcxx::julia_base_type<TArithExpr>());
    mod.add_type<TNegate>("TNegate", jlcxx::julia_base_type<TArithExpr>());
    mod.add_type<TPlus>("TPlus", jlcxx::julia_base_type<TArithExpr>());
    mod.add_type<TMinus>("TMinus", jlcxx::julia_base_type<TArithExpr>());
    mod.add_type<TMultiply>("TMultiply", jlcxx::julia_base_type<TArithExpr>());

    mod.add_type<TBoolExpr>("TBoolExpr", jlcxx::julia_base_type<TNode>())
        .method("to_string", &TBoolExpr::toString);

    mod.add_type<TCompare>("TCompare", jlcxx::julia_base_type<TBoolExpr>());
    mod.add_type<TConnective>("TConnective", jlcxx::julia_base_type<TBoolExpr>());

    mod.add_type<TAssertion>("TAssertion", jlcxx::julia_base_type<TNode>())
        .method("to_string", &TAssertion::toString);

    mod.add_type<TInputDefinition>("TInputDefinition", jlcxx::julia_base_type<TNode>())
        .method("to_string", &TInputDefinition::toString);

    mod.add_type<THiddenDefinition>("THiddenDefinition", jlcxx::julia_base_type<TNode>())
        .method("to_string", &THiddenDefinition::toString);

    mod.add_type<TOutputDefinition>("TOutputDefinition", jlcxx::julia_base_type<TNode>())
        .method("to_string", &TOutputDefinition::toString);

    mod.add_type<TNetworkDefinition>("TNetworkDefinition", jlcxx::julia_base_type<TNode>())
        .method("to_string", &TNetworkDefinition::toString);

    mod.add_type<TVersion>("TVersion", jlcxx::julia_base_type<TNode>())
        .method("to_string", &TVersion::toString);

    mod.add_type<TQuery>("TQuery", jlcxx::julia_base_type<TNode>())
        .method("to_string", &TQuery::toString);

    // Expose utility functions if needed
    // mod.method("dtype_to_string", &dtypeToString);
    // mod.method("shape_to_string", &shapeToString);

    // Existing methods
    mod.method("parse_query", &jl_parse_query);
    mod.method("parse_query_str", &jl_parse_query_str);
    mod.method("check_query", &jl_check_query);
    mod.method("check_query_str", &jl_check_query_str);
}
