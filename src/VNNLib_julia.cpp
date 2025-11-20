// C++ wrapper for VNNLib using CxxWrap
#include <jlcxx/jlcxx.hpp>
#include <jlcxx/stl.hpp>
#include <vector>
#include <memory>
#include "../deps/VNNLIB-CPP/include/VNNLib.h"
#include "../deps/VNNLIB-CPP/include/TypedAbsyn.h"

/*
CxxWrap currently does not support class enums directly,
so we provide a "classical" enum with conversion functions.
*/

enum JuliaDType {
    DReal,
    DF16,
    DF32,
    DF64,
    DBF16,
    DF8E4M3FN,
    DF8E5M2,
    DF8E4M3FNUZ,
    DF8E5M2FNUZ,
    DF4E2M1,
    DI8,
    DI16,
    DI32,
    DI64,
    DU8,
    DU16,
    DU32,
    DU64,
    DC64,
    DC128,
    DBool,
    DString,
    DUnknown,
    DFloatConstant,
    DNegativeIntConstant,
    DPositiveIntConstant
};

enum JuliaSymbolKind {
    SKInput,
    SKHidden,
    SKOutput,
    SKNetwork,
    SKUnknown
};

JuliaSymbolKind to_julia_symbol_kind(SymbolKind sk) {
    switch (sk) {
        case SymbolKind::Input: return SKInput;
        case SymbolKind::Hidden: return SKHidden;
        case SymbolKind::Output: return SKOutput;
        case SymbolKind::Network: return SKNetwork;
        case SymbolKind::Unknown: return SKUnknown;
        default: return SKUnknown; // Fallback
    }
}

SymbolKind to_cpp_symbol_kind(JuliaSymbolKind jsk) {
    switch (jsk) {
        case SKInput: return SymbolKind::Input;
        case SKHidden: return SymbolKind::Hidden;
        case SKOutput: return SymbolKind::Output;
        case SKNetwork: return SymbolKind::Network;
        case SKUnknown: return SymbolKind::Unknown;
        default: return SymbolKind::Unknown; // Fallback
    }
}

JuliaDType to_julia_type_enum(DType dt) {
    switch (dt) {
        case DType::Real: return DReal;
        case DType::F16: return DF16;
        case DType::F32: return DF32;
        case DType::F64: return DF64;
        case DType::BF16: return DBF16;
        case DType::F8E4M3FN: return DF8E4M3FN;
        case DType::F8E5M2: return DF8E5M2;
        case DType::F8E4M3FNUZ: return DF8E4M3FNUZ;
        case DType::F8E5M2FNUZ: return DF8E5M2FNUZ;
        case DType::F4E2M1: return DF4E2M1;
        case DType::I8: return DI8;
        case DType::I16: return DI16;
        case DType::I32: return DI32;
        case DType::I64: return DI64;
        case DType::U8: return DU8;
        case DType::U16: return DU16;
        case DType::U32: return DU32;
        case DType::U64: return DU64;
        case DType::C64: return DC64;
        case DType::C128: return DC128;
        case DType::Bool: return DBool;
        case DType::String: return DString;
        case DType::Unknown: return DUnknown;
        case DType::FloatConstant: return DFloatConstant;
        case DType::NegativeIntConstant: return DNegativeIntConstant;
        case DType::PositiveIntConstant: return DPositiveIntConstant;
        default: return DUnknown; // Fallback
    }
}

DType to_cpp_type_enum(JuliaDType jdt) {
    switch (jdt) {
        case DReal: return DType::Real;
        case DF16: return DType::F16;
        case DF32: return DType::F32;
        case DF64: return DType::F64;
        case DBF16: return DType::BF16;
        case DF8E4M3FN: return DType::F8E4M3FN;
        case DF8E5M2: return DType::F8E5M2;
        case DF8E4M3FNUZ: return DType::F8E4M3FNUZ;
        case DF8E5M2FNUZ: return DType::F8E5M2FNUZ;
        case DF4E2M1: return DType::F4E2M1;
        case DI8: return DType::I8;
        case DI16: return DType::I16;
        case DI32: return DType::I32;
        case DI64: return DType::I64;
        case DU8: return DType::U8;
        case DU16: return DType::U16;
        case DU32: return DType::U32;
        case DU64: return DType::U64;
        case DC64: return DType::C64;
        case DC128: return DType::C128;
        case DBool: return DType::Bool;
        case DString: return DType::String;
        case DUnknown: return DType::Unknown;
        case DFloatConstant: return DType::FloatConstant;
        case DNegativeIntConstant: return DType::NegativeIntConstant;
        case DPositiveIntConstant: return DType::PositiveIntConstant;
        default: return DType::Unknown; // Fallback
    }
}

// Return a shared_ptr<TQuery> by converting the unique_ptr returned by parse_query
std::shared_ptr<TQuery> jl_parse_query(const std::string& path) {
    return parse_query(path);
}

// parse_query_str: return shared_ptr<TQuery> by converting the unique_ptr
std::shared_ptr<TQuery> jl_parse_query_str(const std::string& content) {
    return parse_query_str(content);
}

// check_query: returns result string
std::string jl_check_query(const std::string& path) {
    return check_query(path);
}

// check_query_str: returns result string
std::string jl_check_query_str(const std::string& content) {
    return check_query_str(content);
}

std::vector<const TNode *> jl_children_sp(const TNode& node) {
    std::vector<const TNode*> out;
    node.children(out);
    return out;
}

std::vector<const TNode *> jl_children_ptr_sp(const TNode* node) {
    if (!node) return {};
    return jl_children_sp(*node);
}


// Register super types for inheritance
namespace jlcxx {
    template<> struct SuperType<TElementType> { typedef TNode type; };

    // --- Arithmetic Expressions ---
    template<> struct SuperType<TArithExpr> { typedef TNode type; };

    template<> struct SuperType<TVarExpr> { typedef TArithExpr type; };
    
    template<> struct SuperType<TLiteral> { typedef TArithExpr type; };
    
    template<> struct SuperType<TFloat> { typedef TLiteral type; };
    template<> struct SuperType<TInt> { typedef TLiteral type; };

    template<> struct SuperType<TNegate> { typedef TArithExpr type; };
    template<> struct SuperType<TPlus> { typedef TArithExpr type; };
    template<> struct SuperType<TMinus> { typedef TArithExpr type; };
    template<> struct SuperType<TMultiply> { typedef TArithExpr type; };

    // --- Boolean Expressions ---

    template<> struct SuperType<TBoolExpr> { typedef TNode type; };
    template<> struct SuperType<TCompare> { typedef TBoolExpr type; };
    
    template<> struct SuperType<TGreaterThan> { typedef TCompare type; };
    template<> struct SuperType<TLessThan> { typedef TCompare type; };
    template<> struct SuperType<TGreaterEqual> { typedef TCompare type; };
    template<> struct SuperType<TLessEqual> { typedef TCompare type; };
    template<> struct SuperType<TEqual> { typedef TCompare type; };
    template<> struct SuperType<TNotEqual> { typedef TCompare type; };

    template<> struct SuperType<TConnective> { typedef TBoolExpr type; };

    template<> struct SuperType<TAnd> { typedef TConnective type; };
    template<> struct SuperType<TOr> { typedef TConnective type; };

    // --- Assertion ---
    template<> struct SuperType<TAssertion> { typedef TNode type; };

    // --- Definitions ---
    template<> struct SuperType<TInputDefinition> { typedef TNode type; };
    template<> struct SuperType<THiddenDefinition> { typedef TNode type; };
    template<> struct SuperType<TOutputDefinition> { typedef TNode type; };

    // --- Network ---
    template<> struct SuperType<TNetworkDefinition> { typedef TNode type; };

    // --- Version ---
    template<> struct SuperType<TVersion> { typedef TNode type; };

    // --- Query ---
    template<> struct SuperType<TQuery> { typedef TNode type; };
}

JLCXX_MODULE define_julia_module(jlcxx::Module& mod) {

    mod.add_enum<JuliaDType>("DType",
    std::vector<const char*>({"DReal","DF16","DF32","DF64","DBF16","DF8E4M3FN","DF8E5M2","DF8E4M3FNUZ","DF8E5M2FNUZ","DF4E2M1","DI8","DI16","DI32","DI64","DU8","DU16","DU32","DU64","DC64","DC128","DBool","DString","DUnknown","DFloatConstant","DNegativeIntConstant","DPositiveIntConstant"}),
    std::vector<int>({DReal,DF16,DF32,DF64,DBF16,DF8E4M3FN,DF8E5M2,DF8E4M3FNUZ,DF8E5M2FNUZ,DF4E2M1,DI8,DI16,DI32,DI64,DU8,DU16,DU32,DU64,DC64,DC128,DBool,DString,DUnknown,DFloatConstant,DNegativeIntConstant,DPositiveIntConstant}));

    mod.add_enum<JuliaSymbolKind>("SymbolKind",
    std::vector<const char*>({"Input","Hidden","Output","Network","Unknown"}),
    std::vector<int>({SKInput,SKHidden,SKOutput,SKNetwork,SKUnknown}));

    mod.add_type<SymbolInfo>("SymbolInfo");

    // Register all types and methods from TypedAbsyn.cpp
    mod.add_type<TNode>("TNode")
        .method("children", [](const TNode& n) {
            return jl_children_sp(n);
        })
        .method("children", [](const TNode* n) {
            return jl_children_ptr_sp(n);
        })
        .method("children", [](const std::shared_ptr<TNode>& n) {
            return jl_children_sp(*n);
        })
        .method("to_string", [](const TNode& n) {
            return n.toString();
        })
        .method("to_string", [](const TNode* n) {
            return n ? n->toString() : std::string("");
        })
        .method("to_string", [](const std::shared_ptr<TNode>& n) {
            return n ? n->toString() : std::string("");
        });

    mod.add_type<TElementType>("TElementType", jlcxx::julia_base_type<TNode>());

    mod.add_type<TArithExpr>("TArithExpr", jlcxx::julia_base_type<TNode>())
        .method("dtype", [](const TArithExpr& expr) {
            return to_julia_type_enum(expr.dtype);
        })
        .method("dtype", [](const TArithExpr* expr) {
            return expr ? to_julia_type_enum(expr->dtype) : DUnknown;
        })
        .method("dtype", [](const std::shared_ptr<TArithExpr>& expr) {
            return expr ? to_julia_type_enum(expr->dtype) : DUnknown;
        });

    mod.add_type<TVarExpr>("TVarExpr", jlcxx::julia_base_type<TArithExpr>());
    mod.add_type<TLiteral>("TLiteral", jlcxx::julia_base_type<TArithExpr>());
    mod.add_type<TFloat>("TFloat", jlcxx::julia_base_type<TLiteral>());
    mod.add_type<TInt>("TInt", jlcxx::julia_base_type<TLiteral>());
    mod.add_type<TNegate>("TNegate", jlcxx::julia_base_type<TArithExpr>());
    mod.add_type<TPlus>("TPlus", jlcxx::julia_base_type<TArithExpr>());
    mod.add_type<TMinus>("TMinus", jlcxx::julia_base_type<TArithExpr>());
    mod.add_type<TMultiply>("TMultiply", jlcxx::julia_base_type<TArithExpr>());

    mod.add_type<TBoolExpr>("TBoolExpr", jlcxx::julia_base_type<TNode>());

    mod.add_type<TCompare>("TCompare", jlcxx::julia_base_type<TBoolExpr>());
    mod.add_type<TGreaterThan>("TGreaterThan", jlcxx::julia_base_type<TCompare>());
    mod.add_type<TLessThan>("TLessThan", jlcxx::julia_base_type<TCompare>());
    mod.add_type<TGreaterEqual>("TGreaterEqual", jlcxx::julia_base_type<TCompare>());
    mod.add_type<TLessEqual>("TLessEqual", jlcxx::julia_base_type<TCompare>());
    mod.add_type<TEqual>("TEqual", jlcxx::julia_base_type<TCompare>());
    mod.add_type<TNotEqual>("TNotEqual", jlcxx::julia_base_type<TCompare>());
    mod.add_type<TConnective>("TConnective", jlcxx::julia_base_type<TBoolExpr>());
    mod.add_type<TAnd>("TAnd", jlcxx::julia_base_type<TConnective>());
    mod.add_type<TOr>("TOr", jlcxx::julia_base_type<TConnective>());

    mod.add_type<TAssertion>("TAssertion", jlcxx::julia_base_type<TNode>());

    mod.add_type<TInputDefinition>("TInputDefinition", jlcxx::julia_base_type<TNode>());

    mod.add_type<THiddenDefinition>("THiddenDefinition", jlcxx::julia_base_type<TNode>());

    mod.add_type<TOutputDefinition>("TOutputDefinition", jlcxx::julia_base_type<TNode>());

    mod.add_type<TNetworkDefinition>("TNetworkDefinition", jlcxx::julia_base_type<TNode>());

    mod.add_type<TVersion>("TVersion", jlcxx::julia_base_type<TNode>());

    mod.add_type<TQuery>("TQuery", jlcxx::julia_base_type<TNode>());

    // Existing methods
    mod.method("parse_query", &jl_parse_query);
    mod.method("parse_query_str", &jl_parse_query_str);
    mod.method("check_query", &jl_check_query);
    mod.method("check_query_str", &jl_check_query_str);
}
