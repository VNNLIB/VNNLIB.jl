// C++ wrapper for VNNLib using CxxWrap
#include <jlcxx/jlcxx.hpp>
#include <jlcxx/stl.hpp>
#include <vector>
#include "../deps/VNNLib/include/VNNLib.h"
#include "../deps/VNNLib/include/TypedAbsyn.h"

// parse_query: returns string representation of parsed query
std::string jl_parse_query(const std::string& path) {
    auto query_ptr = parse_query(path);
    if (!query_ptr) return "";
    return query_ptr->toString();
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

std::vector<const TNode*> jl_children(const TNode& node) {
    std::vector<const TNode*> out;
    node.children(out);
    return out;
}

JLCXX_MODULE define_julia_module(jlcxx::Module& mod) {
    // Register all types and methods from TypedAbsyn.cpp
    mod.add_type<TNode>("TNode")
        .method("children", [](const TNode& n) {
            return jl_children(n);
        })
        .method("to_string", &TNode::toString);

    mod.add_type<TElementType>("TElementType")
        .method("to_string", &TElementType::toString);

    mod.add_type<TArithExpr>("TArithExpr")
        .method("to_string", &TArithExpr::toString);

    mod.add_type<TVarExpr>("TVarExpr");

    mod.add_type<TLiteral>("TLiteral");

    mod.add_type<TNegate>("TNegate");

    mod.add_type<TPlus>("TPlus");

    mod.add_type<TMinus>("TMinus");

    mod.add_type<TMultiply>("TMultiply");

    mod.add_type<TBoolExpr>("TBoolExpr")
        .method("to_string", &TBoolExpr::toString);

    mod.add_type<TCompare>("TCompare");

    mod.add_type<TConnective>("TConnective");

    mod.add_type<TAssertion>("TAssertion")
        .method("to_string", &TAssertion::toString);

    mod.add_type<TInputDefinition>("TInputDefinition")
        .method("to_string", &TInputDefinition::toString);

    mod.add_type<THiddenDefinition>("THiddenDefinition")
        .method("to_string", &THiddenDefinition::toString);

    mod.add_type<TOutputDefinition>("TOutputDefinition")
        .method("to_string", &TOutputDefinition::toString);

    mod.add_type<TNetworkDefinition>("TNetworkDefinition")
        .method("to_string", &TNetworkDefinition::toString);

    mod.add_type<TVersion>("TVersion")
        .method("to_string", &TVersion::toString);

    mod.add_type<TQuery>("TQuery")
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
