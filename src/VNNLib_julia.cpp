// C++ wrapper for VNNLib using CxxWrap
#include <jlcxx/jlcxx.hpp>
#include <jlcxx/stl.hpp>
#include <vector>
#include <memory>
#include "../deps/VNNLIB-CPP/include/VNNLib.h"
#include "../deps/VNNLIB-CPP/include/TypedAbsyn.h"
#include "../deps/VNNLIB-CPP/include/LinearArithExpr.h"
#include "../deps/VNNLIB-CPP/include/DNFConverter.h"
#include "../deps/VNNLIB-CPP/include/CompatTransformer.h"

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

    auto linarithexprterm_type = mod.add_type<LinearArithExpr::Term>("LinearArithExprTerm")
        .method("coeff", [](const LinearArithExpr::Term& t) {
            return t.coeff;
        })
        .method("coeff", [](const LinearArithExpr::Term* t) {
            if (!t) return 0.0;
            return t->coeff;
        })
        .method("coeff", [](const std::shared_ptr<LinearArithExpr::Term>& t) {
            if (!t) return 0.0;
            return t->coeff;
        })
        .method("var_name", [](const LinearArithExpr::Term& t) {
            return t.varName;
        })
        .method("var_name", [](const LinearArithExpr::Term* t) {
            if (!t) return std::string("");
            return t->varName;
        })
        .method("var_name", [](const std::shared_ptr<LinearArithExpr::Term>& t) {
            if (!t) return std::string("");
            return t->varName;
        });
        // Additional methods after instantiation of VarExpr

    mod.add_type<LinearArithExpr>("LinearArithExpr")
        .method("to_string", [](const LinearArithExpr& n) {
            return n.toString();
        })
        .method("to_string", [](const LinearArithExpr* n) {
            return n ? n->toString() : std::string("");
        })
        .method("to_string", [](const std::shared_ptr<LinearArithExpr>& n) {
            return n ? n->toString() : std::string("");
        })
        .method("terms", [](const LinearArithExpr& expr) {
            return expr.getTerms();
        })
        .method("terms", [](const LinearArithExpr* expr) {
            if (!expr) return std::vector<LinearArithExpr::Term>{};
            return expr->getTerms();
        })
        .method("terms", [](const std::shared_ptr<LinearArithExpr>& expr) {
            if (!expr) return std::vector<LinearArithExpr::Term>{};
            return expr->getTerms();
        })
        .method("constant", [](const LinearArithExpr& expr) {
            return expr.getConstant();
        })
        .method("constant", [](const LinearArithExpr* expr) {
            if (!expr) return 0.0;
            return expr->getConstant();
        })
        .method("constant", [](const std::shared_ptr<LinearArithExpr>& expr){
            if (!expr) return 0.0;
            return expr->getConstant();
        });
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
        })
        .method("linearize", [](const TArithExpr& expr) {
            auto lin_expr = linearize(&expr);
            return lin_expr.release();
        })
        .method("linearize", [](const TArithExpr* expr) {
            if (!expr) return static_cast<LinearArithExpr*>(nullptr);
            auto lin_expr = linearize(expr);
            return lin_expr.release();
        })
        .method("linearize", [](const std::shared_ptr<TArithExpr>& expr) {
            if (!expr) return static_cast<LinearArithExpr*>(nullptr);
            auto lin_expr = linearize(expr.get());
            return lin_expr.release();
        });


    mod.add_type<TVarExpr>("TVarExpr", jlcxx::julia_base_type<TArithExpr>())
        .method("name", [](const TVarExpr& var) {
            if (var.symbol) {
                return var.symbol->name;
            } else {
                return std::string("");
            }
        })
        .method("name", [](const TVarExpr* var) {
            if (!var || !var->symbol) return std::string("");
            return var->symbol->name;
        })
        .method("name", [](const std::shared_ptr<TVarExpr>& var) {
            if (!var || !var->symbol) return std::string("");
            return var->symbol->name;
        })
        .method("onnx_name", [](const TVarExpr& var) {
            if (var.symbol) {
                return var.symbol->onnxName;
            } else {
                return std::string("");
            }
        })
        .method("onnx_name", [](const TVarExpr* var) {
            if (!var || !var->symbol) return std::string("");
            return var->symbol->onnxName;
        })
        .method("onnx_name", [](const std::shared_ptr<TVarExpr>& var) {
            if (!var || !var->symbol) return std::string("");
            return var->symbol->onnxName;
        })
        .method("dtype", [](const TVarExpr& var) {
            if (var.symbol) {
                return to_julia_type_enum(var.symbol->dtype);
            } else {
                return DUnknown;
            }
        })
        .method("dtype", [](const TVarExpr* var) {
            if (!var || !var->symbol) return DUnknown;
            return to_julia_type_enum(var->symbol->dtype);
        })
        .method("dtype", [](const std::shared_ptr<TVarExpr>& var) {
            if (!var || !var->symbol) return DUnknown;
            return to_julia_type_enum(var->symbol->dtype);
        })
        .method("shape", [](const TVarExpr& var) {
            if (var.symbol) {
                return var.symbol->shape;
            } else {
                return std::vector<int64_t>{};
            }
        })
        .method("shape", [](const TVarExpr* var) {
            if (!var || !var->symbol) return std::vector<int64_t>{};
            return var->symbol->shape;
        })
        .method("shape", [](const std::shared_ptr<TVarExpr>& var) {
            if (!var || !var->symbol) return std::vector<int64_t>{};
            return var->symbol->shape;
        })
        .method("kind", [](const TVarExpr& var) {
            if (var.symbol) {
                return to_julia_symbol_kind(var.symbol->kind);
            } else {
                return SKUnknown;
            }
        })
        .method("kind", [](const TVarExpr* var) {
            if (!var || !var->symbol) return SKUnknown;
            return to_julia_symbol_kind(var->symbol->kind);
        })
        .method("kind", [](const std::shared_ptr<TVarExpr>& var) {
            if (!var || !var->symbol) return SKUnknown;
            return to_julia_symbol_kind(var->symbol->kind);
        })
        .method("network_name", [](const TVarExpr& var) {
            if (var.symbol) {
                return var.symbol->networkName;
            } else {
                return std::string("");
            }
        })
        .method("network_name", [](const TVarExpr* var) {
            if (!var || !var->symbol) return std::string("");
            return var->symbol->networkName;
        })
        .method("network_name", [](const std::shared_ptr<TVarExpr>& var) {
            if (!var || !var->symbol) return std::string("");
            return var->symbol->networkName;
        })
        .method("indices", [](const TVarExpr& var) {
            return var.indices;
        })
        .method("indices", [](const TVarExpr* var) {
            if (!var) return std::vector<int64_t>{};
            return var->indices;
        })
        .method("indices", [](const std::shared_ptr<TVarExpr>& var) {
            if (!var) return std::vector<int64_t>{};
            return var->indices;
        })
        .method("line", [](const TVarExpr& var) {
            return var.line;
        })
        .method("line", [](const TVarExpr* var) {
            if (!var) return -1;
            return var->line;
        })
        .method("line", [](const std::shared_ptr<TVarExpr>& var) {
            if (!var) return -1;
            return var->line;
        });
    mod.add_type<TLiteral>("TLiteral", jlcxx::julia_base_type<TArithExpr>())
        .method("lexeme", [](const TLiteral& lit) {
            return lit.lexeme;
        })
        .method("lexeme", [](const TLiteral* lit) {
            if (!lit) return std::string("");
            return lit->lexeme;
        })
        .method("lexeme", [](const std::shared_ptr<TLiteral>& lit) {
            if (!lit) return std::string("");
            return lit->lexeme;
        })
        .method("line", [](const TLiteral& lit) {
            return lit.line;
        })
        .method("line", [](const TLiteral* lit) {
            if (!lit) return -1;
            return lit->line;
        })
        .method("line", [](const std::shared_ptr<TLiteral>& lit) {
            if (!lit) return -1;
            return lit->line;
        });
    mod.add_type<TFloat>("TFloat", jlcxx::julia_base_type<TLiteral>())
        .method("value", [](const TFloat& f) {
            return f.value;
        })
        .method("value", [](const TFloat* f) {
            if (!f) return std::nan("1");
            return f->value;
        })
        .method("value", [](const std::shared_ptr<TFloat>& f) {
            if (!f) return std::nan("1");
            return f->value;
        });
    mod.add_type<TInt>("TInt", jlcxx::julia_base_type<TLiteral>())
        .method("value", [](const TInt& i) {
            return i.value;
        })
        .method("value", [](const TInt* i) {
            if (!i) return int64_t(0);
            return i->value;
        })
        .method("value", [](const std::shared_ptr<TInt>& i) {
            if (!i) return int64_t(0);
            return i->value;
        });
    mod.add_type<TNegate>("TNegate", jlcxx::julia_base_type<TArithExpr>())
        .method("expr", [](const TNegate& n) {
            return n.expr.get();
        })
        .method("expr", [](const TNegate* n) {
            if (!n) return static_cast<TArithExpr*>(nullptr);
            return n->expr.get();
        })
        .method("expr", [](const std::shared_ptr<TNegate>& n) {
            if (!n) return static_cast<TArithExpr*>(nullptr);
            return n->expr.get();
        });
    mod.add_type<TPlus>("TPlus", jlcxx::julia_base_type<TArithExpr>())
        .method("args", [](const TPlus& p) {
            std::vector<TArithExpr*> out;
            out.reserve(p.args.size());
            for (size_t i = 0; i < p.args.size(); ++i) {
                out.push_back(p.args[i].get());
            }
            return out;
        })
        .method("args", [](const TPlus* p) {
            if (!p) return std::vector<TArithExpr*>{};
            std::vector<TArithExpr*> out;
            out.reserve(p->args.size());
            for (size_t i = 0; i < p->args.size(); ++i) {
                out.push_back(p->args[i].get());
            }
            return out;
        })
        .method("args", [](const std::shared_ptr<TPlus>& p) {
            if (!p) return std::vector<TArithExpr*>{};
            std::vector<TArithExpr*> out;
            out.reserve(p->args.size());
            for (size_t i = 0; i < p->args.size(); ++i) {
                out.push_back(p->args[i].get());
            }
            return out;
        });
    mod.add_type<TMinus>("TMinus", jlcxx::julia_base_type<TArithExpr>())
        .method("args", [](const TMinus& p) {
            std::vector<TArithExpr*> out;
            out.reserve(p.rest.size()+1);
            out.push_back(p.head.get());
            for (size_t i = 0; i < p.rest.size(); ++i) {
                out.push_back(p.rest[i].get());
            }
            return out;
        })
        .method("args", [](const TMinus* p) {
            if (!p) return std::vector<TArithExpr*>{};
            std::vector<TArithExpr*> out;
            out.reserve(p->rest.size()+1);
            out.push_back(p->head.get());
            for (size_t i = 0; i < p->rest.size(); ++i) {
                out.push_back(p->rest[i].get());
            }
            return out;
        })
        .method("args", [](const std::shared_ptr<TMinus>& p) {
            if (!p) return std::vector<TArithExpr*>{};
            std::vector<TArithExpr*> out;
            out.reserve(p->rest.size()+1);
            out.push_back(p->head.get());
            for (size_t i = 0; i < p->rest.size(); ++i) {
                out.push_back(p->rest[i].get());
            }
            return out;
        });
    mod.add_type<TMultiply>("TMultiply", jlcxx::julia_base_type<TArithExpr>())
        .method("args", [](const TMultiply& p) {
            std::vector<TArithExpr*> out;
            out.reserve(p.args.size());
            for (size_t i = 0; i < p.args.size(); ++i) {
                out.push_back(p.args[i].get());
            }
            return out;
        })
        .method("args", [](const TMultiply* p) {
            if (!p) return std::vector<TArithExpr*>{};
            std::vector<TArithExpr*> out;
            out.reserve(p->args.size());
            for (size_t i = 0; i < p->args.size(); ++i) {
                out.push_back(p->args[i].get());
            }
            return out;
        })
        .method("args", [](const std::shared_ptr<TMultiply>& p) {
            if (!p) return std::vector<TArithExpr*>{};
            std::vector<TArithExpr*> out;
            out.reserve(p->args.size());
            for (size_t i = 0; i < p->args.size(); ++i) {
                out.push_back(p->args[i].get());
            }
            return out;
        });

    auto bool_expr_type = mod.add_type<TBoolExpr>("TBoolExpr", jlcxx::julia_base_type<TNode>());
    // TODO: dnf_form

    mod.add_type<TCompare>("TCompare", jlcxx::julia_base_type<TBoolExpr>())
        .method("lhs", [](const TCompare& c) {
            return c.lhs.get();
        })
        .method("lhs", [](const TCompare* c) {
            if (!c) return static_cast<TArithExpr*>(nullptr);
            return c->lhs.get();
        })
        .method("lhs", [](const std::shared_ptr<TCompare>& c) {
            if (!c) return static_cast<TArithExpr*>(nullptr);
            return c->lhs.get();
        })
        .method("rhs", [](const TCompare& c) {
            return c.rhs.get();
        })
        .method("rhs", [](const TCompare* c) {
            if (!c) return static_cast<TArithExpr*>(nullptr);
            return c->rhs.get();
        })
        .method("rhs", [](const std::shared_ptr<TCompare>& c) {
            if (!c) return static_cast<TArithExpr*>(nullptr);
            return c->rhs.get();
        });
    mod.add_type<TGreaterThan>("TGreaterThan", jlcxx::julia_base_type<TCompare>());
    mod.add_type<TLessThan>("TLessThan", jlcxx::julia_base_type<TCompare>());
    mod.add_type<TGreaterEqual>("TGreaterEqual", jlcxx::julia_base_type<TCompare>());
    mod.add_type<TLessEqual>("TLessEqual", jlcxx::julia_base_type<TCompare>());
    mod.add_type<TEqual>("TEqual", jlcxx::julia_base_type<TCompare>());
    mod.add_type<TNotEqual>("TNotEqual", jlcxx::julia_base_type<TCompare>());

    mod.add_type<TConnective>("TConnective", jlcxx::julia_base_type<TBoolExpr>())
        .method("args", [](const TConnective& c) {
            std::vector<TBoolExpr*> out;
            out.reserve(c.args.size());
            for (size_t i = 0; i < c.args.size(); ++i) {
                out.push_back(c.args[i].get());
            }
            return out;
        })
        .method("args", [](const TConnective* c) {
            if (!c) return std::vector<TBoolExpr*>{};
            std::vector<TBoolExpr*> out;
            out.reserve(c->args.size());
            for (size_t i = 0; i < c->args.size(); ++i) {
                out.push_back(c->args[i].get());
            }
            return out;
        })
        .method("args", [](const std::shared_ptr<TConnective>& c) {
            if (!c) return std::vector<TBoolExpr*>{};
            std::vector<TBoolExpr*> out;
            out.reserve(c->args.size());
            for (size_t i = 0; i < c->args.size(); ++i) {
                out.push_back(c->args[i].get());
            }
            return out;
        });
    mod.add_type<TAnd>("TAnd", jlcxx::julia_base_type<TConnective>());
    mod.add_type<TOr>("TOr", jlcxx::julia_base_type<TConnective>());

    mod.add_type<TAssertion>("TAssertion", jlcxx::julia_base_type<TNode>())
        .method("expr", [](const TAssertion& a) {
            return a.cond.get();
        })
        .method("expr", [](const TAssertion* a) {
            if (!a) return static_cast<TBoolExpr*>(nullptr);
            return a->cond.get();
        })
        .method("expr", [](const std::shared_ptr<TAssertion>& a) {
            if (!a) return static_cast<TBoolExpr*>(nullptr);
            return a->cond.get();
        });

    mod.add_type<TInputDefinition>("TInputDefinition", jlcxx::julia_base_type<TNode>())
        .method("name", [](const TInputDefinition& def) {
            return def.symbol->name;
        })
        .method("name", [](const TInputDefinition* def) {
            return def ? def->symbol->name : std::string("");
        })
        .method("name", [](const std::shared_ptr<TInputDefinition>& def) {
            return def ? def->symbol->name : std::string("");
        })
        .method("onnx_name", [](const TInputDefinition& def) {
            return def.symbol->onnxName;
        })
        .method("onnx_name", [](const TInputDefinition* def) {
            return def ? def->symbol->onnxName : std::string("");
        })
        .method("onnx_name", [](const std::shared_ptr<TInputDefinition>& def) {
            return def ? def->symbol->onnxName : std::string("");
        })
        .method("dtype", [](const TInputDefinition& def) {
            return to_julia_type_enum(def.symbol->dtype);
        })
        .method("dtype", [](const TInputDefinition* def) {
            return def ? to_julia_type_enum(def->symbol->dtype) : DUnknown;
        })
        .method("dtype", [](const std::shared_ptr<TInputDefinition>& def) {
            return def ? to_julia_type_enum(def->symbol->dtype) : DUnknown;
        })
        .method("shape", [](const TInputDefinition& def) {
            return def.symbol->shape;
        })
        .method("shape", [](const TInputDefinition* def) {
            return def ? def->symbol->shape : std::vector<int64_t>{};
        })
        .method("shape", [](const std::shared_ptr<TInputDefinition>& def) {
            return def ? def->symbol->shape : std::vector<int64_t>{};
        })
        .method("kind", [](const TInputDefinition& def) {
            return to_julia_symbol_kind(def.symbol->kind);
        })
        .method("kind", [](const TInputDefinition* def) {
            return def ? to_julia_symbol_kind(def->symbol->kind) : SKUnknown;
        })
        .method("kind", [](const std::shared_ptr<TInputDefinition>& def) {
            return def ? to_julia_symbol_kind(def->symbol->kind) : SKUnknown;
        })
        .method("network_name", [](const TInputDefinition& def) {
            return def.symbol->networkName;
        })
        .method("network_name", [](const TInputDefinition* def) {
            return def ? def->symbol->networkName : std::string("");
        })
        .method("network_name", [](const std::shared_ptr<TInputDefinition>& def) {
            return def ? def->symbol->networkName : std::string("");
        });

    mod.add_type<THiddenDefinition>("THiddenDefinition", jlcxx::julia_base_type<TNode>())
        .method("name", [](const THiddenDefinition& def) {
            return def.symbol->name;
        })
        .method("name", [](const THiddenDefinition* def) {
            return def ? def->symbol->name : std::string("");
        })
        .method("name", [](const std::shared_ptr<THiddenDefinition>& def) {
            return def ? def->symbol->name : std::string("");
        })
        .method("onnx_name", [](const THiddenDefinition& def) {
            return def.symbol->onnxName;
        })
        .method("onnx_name", [](const THiddenDefinition* def) {
            return def ? def->symbol->onnxName : std::string("");
        })
        .method("onnx_name", [](const std::shared_ptr<THiddenDefinition>& def) {
            return def ? def->symbol->onnxName : std::string("");
        })
        .method("dtype", [](const THiddenDefinition& def) {
            return to_julia_type_enum(def.symbol->dtype);
        })
        .method("dtype", [](const THiddenDefinition* def) {
            return def ? to_julia_type_enum(def->symbol->dtype) : DUnknown;
        })
        .method("dtype", [](const std::shared_ptr<THiddenDefinition>& def) {
            return def ? to_julia_type_enum(def->symbol->dtype) : DUnknown;
        })
        .method("shape", [](const THiddenDefinition& def) {
            return def.symbol->shape;
        })
        .method("shape", [](const THiddenDefinition* def) {
            return def ? def->symbol->shape : std::vector<int64_t>{};
        })
        .method("shape", [](const std::shared_ptr<THiddenDefinition>& def) {
            return def ? def->symbol->shape : std::vector<int64_t>{};
        })
        .method("kind", [](const THiddenDefinition& def) {
            return to_julia_symbol_kind(def.symbol->kind);
        })
        .method("kind", [](const THiddenDefinition* def) {
            return def ? to_julia_symbol_kind(def->symbol->kind) : SKUnknown;
        })
        .method("kind", [](const std::shared_ptr<THiddenDefinition>& def) {
            return def ? to_julia_symbol_kind(def->symbol->kind) : SKUnknown;
        })
        .method("network_name", [](const THiddenDefinition& def) {
            return def.symbol->networkName;
        })
        .method("network_name", [](const THiddenDefinition* def) {
            return def ? def->symbol->networkName : std::string("");
        })
        .method("network_name", [](const std::shared_ptr<THiddenDefinition>& def) {
            return def ? def->symbol->networkName : std::string("");
        });

    mod.add_type<TOutputDefinition>("TOutputDefinition", jlcxx::julia_base_type<TNode>())
        .method("name", [](const TOutputDefinition& def) {
            return def.symbol->name;
        })
        .method("name", [](const TOutputDefinition* def) {
            return def ? def->symbol->name : std::string("");
        })
        .method("name", [](const std::shared_ptr<TOutputDefinition>& def) {
            return def ? def->symbol->name : std::string("");
        })
        .method("onnx_name", [](const TOutputDefinition& def) {
            return def.symbol->onnxName;
        })
        .method("onnx_name", [](const TOutputDefinition* def) {
            return def ? def->symbol->onnxName : std::string("");
        })
        .method("onnx_name", [](const std::shared_ptr<TOutputDefinition>& def) {
            return def ? def->symbol->onnxName : std::string("");
        })
        .method("dtype", [](const TOutputDefinition& def) {
            return to_julia_type_enum(def.symbol->dtype);
        })
        .method("dtype", [](const TOutputDefinition* def) {
            return def ? to_julia_type_enum(def->symbol->dtype) : DUnknown;
        })
        .method("dtype", [](const std::shared_ptr<TOutputDefinition>& def) {
            return def ? to_julia_type_enum(def->symbol->dtype) : DUnknown;
        })
        .method("shape", [](const TOutputDefinition& def) {
            return def.symbol->shape;
        })
        .method("shape", [](const TOutputDefinition* def) {
            return def ? def->symbol->shape : std::vector<int64_t>{};
        })
        .method("shape", [](const std::shared_ptr<TOutputDefinition>& def) {
            return def ? def->symbol->shape : std::vector<int64_t>{};
        })
        .method("kind", [](const TOutputDefinition& def) {
            return to_julia_symbol_kind(def.symbol->kind);
        })
        .method("kind", [](const TOutputDefinition* def) {
            return def ? to_julia_symbol_kind(def->symbol->kind) : SKUnknown;
        })
        .method("kind", [](const std::shared_ptr<TOutputDefinition>& def) {
            return def ? to_julia_symbol_kind(def->symbol->kind) : SKUnknown;
        })
        .method("network_name", [](const TOutputDefinition& def) {
            return def.symbol->networkName;
        })
        .method("network_name", [](const TOutputDefinition* def) {
            return def ? def->symbol->networkName : std::string("");
        })
        .method("network_name", [](const std::shared_ptr<TOutputDefinition>& def) {
            return def ? def->symbol->networkName : std::string("");
        });

    mod.add_type<TNetworkDefinition>("TNetworkDefinition", jlcxx::julia_base_type<TNode>())
        .method("name", [](const TNetworkDefinition& net) {
            return net.networkName;
        })
        .method("name", [](const TNetworkDefinition* net) {
            return net ? net->networkName : std::string("");
        })
        .method("name", [](const std::shared_ptr<TNetworkDefinition>& net) {
            return net ? net->networkName : std::string("");
        })
        .method("net_isometric_to", [](const TNetworkDefinition& net) {
            return net.isometricTo;
        })
        .method("net_isometric_to", [](const TNetworkDefinition* net) {
            return net ? net->isometricTo : std::string("");
        })
        .method("net_isometric_to", [](const std::shared_ptr<TNetworkDefinition>& net) {
            return net ? net->isometricTo : std::string("");
        })
        .method("net_equal_to", [](const TNetworkDefinition& net) {
            return net.equalTo;
        })
        .method("net_equal_to", [](const TNetworkDefinition* net) {
            return net ? net->equalTo : std::string("");
        })
        .method("net_equal_to", [](const std::shared_ptr<TNetworkDefinition>& net) {
            return net ? net->equalTo : std::string("");
        })
        .method("net_inputs", [](const TNetworkDefinition& net) {
            std::vector<const TInputDefinition*> out;
            out.reserve(net.inputs.size());
            for (const auto& inp : net.inputs) {
                out.push_back(inp.get());
            }
            return out;
        })
        .method("net_inputs", [](const TNetworkDefinition* net) {
            if (!net) return std::vector<const TInputDefinition*>{};
            std::vector<const TInputDefinition*> out;
            out.reserve(net->inputs.size());
            for (const auto& inp : net->inputs) {
                out.push_back(inp.get());
            }
            return out;
        })
        .method("net_inputs", [](const std::shared_ptr<TNetworkDefinition>& net) {
            if (!net) return std::vector<const TInputDefinition*>{};
            std::vector<const TInputDefinition*> out;
            out.reserve(net->inputs.size());
            for (const auto& inp : net->inputs) {
                out.push_back(inp.get());
            }
            return out;
        })
        .method("net_outputs", [](const TNetworkDefinition& net) {
            std::vector<const TOutputDefinition*> out;
            out.reserve(net.outputs.size());
            for (const auto& outp : net.outputs) {
                out.push_back(outp.get());
            }
            return out;
        })
        .method("net_outputs", [](const TNetworkDefinition* net) {
            if (!net) return std::vector<const TOutputDefinition*>{};
            std::vector<const TOutputDefinition*> out;
            out.reserve(net->outputs.size());
            for (const auto& outp : net->outputs) {
                out.push_back(outp.get());
            }
            return out;
        })
        .method("net_outputs", [](const std::shared_ptr<TNetworkDefinition>& net) {
            if (!net) return std::vector<const TOutputDefinition*>{};
            std::vector<const TOutputDefinition*> out;
            out.reserve(net->outputs.size());
            for (const auto& outp : net->outputs) {
                out.push_back(outp.get());
            }
            return out;
        })
        .method("net_hidden", [](const TNetworkDefinition& net) {
            std::vector<const THiddenDefinition*> out;
            out.reserve(net.hidden.size());
            for (const auto& hid : net.hidden) {
                out.push_back(hid.get());
            }
            return out;
        })
        .method("net_hidden", [](const TNetworkDefinition* net) {
            if (!net) return std::vector<const THiddenDefinition*>{};
            std::vector<const THiddenDefinition*> out;
            out.reserve(net->hidden.size());
            for (const auto& hid : net->hidden) {
                out.push_back(hid.get());
            }
            return out;
        })
        .method("net_hidden", [](const std::shared_ptr<TNetworkDefinition>& net) {
            if (!net) return std::vector<const THiddenDefinition*>{};
            std::vector<const THiddenDefinition*> out;
            out.reserve(net->hidden.size());
            for (const auto& hid : net->hidden) {
                out.push_back(hid.get());
            }
            return out;
        });

    mod.add_type<TVersion>("TVersion", jlcxx::julia_base_type<TNode>())
        .method("version_major", [](const TVersion& v) {
            return v.major;
        })
        .method("version_major", [](const TVersion* v) {
            if (!v) return 0;
            return v->major;
        })
        .method("version_major", [](const std::shared_ptr<TVersion>& v) {
            if (!v) return 0;
            return v->major;
        })
        .method("version_minor", [](const TVersion& v) {
            return v.minor;
        })
        .method("version_minor", [](const TVersion* v) {
            if (!v) return 0;
            return v->minor;
        })
        .method("version_minor", [](const std::shared_ptr<TVersion>& v) {
            if (!v) return 0;
            return v->minor;
        });

    mod.add_type<TQuery>("TQuery", jlcxx::julia_base_type<TNode>())
        .method("networks", [](const TQuery& q) {
            std::vector<const TNetworkDefinition*> out;
            out.reserve(q.networks.size());
            for (const auto& net : q.networks) {
                out.push_back(net.get());
            }
            return out;
        })
        .method("networks", [](const TQuery* q) {
            if (!q) return std::vector<const TNetworkDefinition*>{};
            std::vector<const TNetworkDefinition*> out;
            out.reserve(q->networks.size());
            for (const auto& net : q->networks) {
                out.push_back(net.get());
            }
            return out;
        })
        .method("networks", [](const std::shared_ptr<TQuery>& q) {
            if (!q) return std::vector<const TNetworkDefinition*>{};
            std::vector<const TNetworkDefinition*> out;
            out.reserve(q->networks.size());
            for (const auto& net : q->networks) {
                out.push_back(net.get());
            }
            return out;
        })
        .method("assertions", [](const TQuery& q) {
            std::vector<const TAssertion*> out;
            out.reserve(q.assertions.size());
            for (const auto& a : q.assertions) {
                out.push_back(a.get());
            }
            return out;
        })
        .method("assertions", [](const TQuery* q) {
            if (!q) return std::vector<const TAssertion*>{};
            std::vector<const TAssertion*> out;
            out.reserve(q->assertions.size());
            for (const auto& a : q->assertions) {
                out.push_back(a.get());
            }
            return out;
        })
        .method("assertions", [](const std::shared_ptr<TQuery>& q) {
            if (!q) return std::vector<const TAssertion*>{};
            std::vector<const TAssertion*> out;
            out.reserve(q->assertions.size());
            for (const auto& a : q->assertions) {
                out.push_back(a.get());
            }
            return out;
        });

    // TODO: Compatibility modes

    linarithexprterm_type
        .method("var", [](const LinearArithExpr::Term& t) {
            return t.var;
        })
        .method("var", [](const LinearArithExpr::Term* t) {
            if (!t) return static_cast<const TVarExpr*>(nullptr);
            return t->var;
        })
        .method("var", [](const std::shared_ptr<LinearArithExpr::Term>& t) {
            if (!t) return static_cast<const TVarExpr*>(nullptr);
            return t->var;
        });

    bool_expr_type
        .method("to_dnf", [](const TBoolExpr& b) {
            return toDNF(&b);
        })
        .method("to_dnf", [](const TBoolExpr* b) {
            if (!b) return DNF{};
            return toDNF(b);
        })
        .method("to_dnf", [](const std::shared_ptr<TBoolExpr>& b) {
            if (!b) return DNF{};
            return toDNF(b.get());
        });

    mod.add_type<Polytope>("Polytope")
        .method("coeff_matrix", [](const Polytope& p) {
            return p.coeffMatrix;
        })
        .method("coeff_matrix", [](const Polytope* p) {
            if (!p) return std::vector<std::vector<double>>{};
            return p->coeffMatrix;
        })
        .method("coeff_matrix", [](const std::shared_ptr<Polytope>& p) {
            if (!p) return std::vector<std::vector<double>>{};
            return p->coeffMatrix;
        })
        .method("rhs", [](const Polytope& p) {
            return p.rhs;
        })
        .method("rhs", [](const Polytope* p) {
            if (!p) return std::vector<double>{};
            return p->rhs;
        })
        .method("rhs", [](const std::shared_ptr<Polytope>& p) {
            if (!p) return std::vector<double>{};
            return p->rhs;
        });
    mod.add_type<SpecCase>("SpecCase")
        .method("input_box", [](const SpecCase& sc) {
            std::vector<std::vector<double>> out;
            out.reserve(sc.inputBox.size());
            for (const std::pair<double, double>& interval : sc.inputBox) {
                out.push_back({interval.first, interval.second});
            }
            return out;
        })
        .method("input_box", [](const SpecCase* sc) {
            if (!sc) return std::vector<std::vector<double>>{};
            std::vector<std::vector<double>> out;
            out.reserve(sc->inputBox.size());
            for (const std::pair<double, double>& interval : sc->inputBox) {
                out.push_back({interval.first, interval.second});
            }
            return out;
        })
        .method("input_box", [](const std::shared_ptr<SpecCase>& sc) {
            if (!sc) return std::vector<std::vector<double>>{};
            std::vector<std::vector<double>> out;
            out.reserve(sc->inputBox.size());
            for (const std::pair<double, double>& interval : sc->inputBox) {
                out.push_back({interval.first, interval.second});
            }
            return out;
        })
        .method("output_constraints", [](const SpecCase& sc) {
            std::vector<const Polytope*> out;
            out.reserve(sc.outputConstraints.size());
            for (const Polytope& p : sc.outputConstraints) {
                out.push_back(&p);
            }
            return out;
        })
        .method("output_constraints", [](const SpecCase* sc) {
            if (!sc) return std::vector<const Polytope*>{};
            std::vector<const Polytope*> out;
            out.reserve(sc->outputConstraints.size());
            for (const Polytope& p : sc->outputConstraints) {
                out.push_back(&p);
            }
            return out;
        })
        .method("output_constraints", [](const std::shared_ptr<SpecCase>& sc) {
            if (!sc) return std::vector<const Polytope*>{};
            std::vector<const Polytope*> out;
            out.reserve(sc->outputConstraints.size());
            for (const Polytope& p : sc->outputConstraints) {
                out.push_back(&p);
            }
            return out;
        });
    // Existing methods
    mod.method("parse_query", &jl_parse_query);
    mod.method("parse_query_str", &jl_parse_query_str);
    mod.method("check_query", &jl_check_query);
    mod.method("check_query_str", &jl_check_query_str);
    mod.method("transform_to_compat", [](const TQuery& q) {
        CompatTransformer transformer(&q);
        return transformer.transform();
    });
    mod.method("transform_to_compat", [](const TQuery* q) {
        if (!q) return std::vector<SpecCase>{};
        CompatTransformer transformer(q);
        return transformer.transform();
    });
    mod.method("transform_to_compat", [](const std::shared_ptr<TQuery>& q) {
        if (!q) return std::vector<SpecCase>{};
        CompatTransformer transformer(q.get());
        return transformer.transform();
    });
}
