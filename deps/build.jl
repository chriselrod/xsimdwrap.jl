using VectorizationBase: REGISTER_SIZE

const float_to_float = [
    # "abs", "fabs",
    "exp", "exp2", "exp10", "expm1", "log", "log2", "log10", "log1p",
    "sin", "cos", "tan",  "asin", "acos", "atan", 
    "sinh", "cosh", "tanh", "asinh", "acosh", "atanh",
    "erf", "erfc", "tgamma", "lgamma"
]
const floatfloat_to_float = [
    # "fmod", "remainder", "min", "max", "fmin", "fmax", "fdim",
    "pow", "hypot", "atan2"
]
const float_to_floatfloat = [
    "sincos"
]

function gen_cpp_code()
    bits = (128, 256, 512)
    native_bits = REGISTER_SIZE << 3
    cxx_code = """
    #include "xsimd/xsimd.hpp"
    #include <immintrin.h>
    
    namespace xs = xsimd;
    
    extern "C" {
    """
    for f ∈ float_to_float
        for bitcount ∈ bits
            bitcount > native_bits && continue
            cxx_code *= """
            __m$(bitcount)d xsimd_$(f)_$(bitcount)d(const __m$(bitcount)d a){
                const auto b = xs::batch<double,$(bitcount >> 6)>(a);
                auto fb = xs::$(f)(b);
                return fb;
            }
            __m$(bitcount) xsimd_$(f)_$(bitcount)(const __m$(bitcount) a){
                const auto b = xs::batch<float,$(bitcount >> 5)>(a);
                auto fb = xs::$(f)(b);
                return fb;
            }
            """
        end
    end
    for f ∈ floatfloat_to_float
        for bitcount ∈ bits
            bitcount > native_bits && continue
            cxx_code *= """
            __m$(bitcount)d xsimd_$(f)_$(bitcount)d(const __m$(bitcount)d a, const __m$(bitcount)d c){
                const auto b = xs::batch<double,$(bitcount >> 6)>(a);
                const auto d = xs::batch<double,$(bitcount >> 6)>(c);
                auto fbd = xs::$(f)(b, d);
                return fbd;
            }
            __m$(bitcount) xsimd_$(f)_$(bitcount)(const __m$(bitcount) a, const __m$(bitcount) c){
                const auto b = xs::batch<float,$(bitcount >> 5)>(a);
                const auto d = xs::batch<float,$(bitcount >> 5)>(c);
                auto fbd = xs::$(f)(b, d);
                return fbd;
            }
            """
        end
    end
    for f ∈ float_to_floatfloat
        for bitcount ∈ bits
            bitcount > native_bits && continue
            cxx_code *= """
            std::pair<__m$(bitcount)d,__m$(bitcount)d> xsimd_$(f)_$(bitcount)d(const __m$(bitcount)d a){
                const auto b = xs::batch<double,$(bitcount >> 6)>(a);
                xs::batch<double,$(bitcount >> 6)> sb, cb;
                xs::$(f)(b, sb, cb);
                __m$(bitcount)d s = sb;
                __m$(bitcount)d c = cb;
                return std::make_pair(s,c);
            }
            std::pair<__m$(bitcount),__m$(bitcount)> xsimd_$(f)_$(bitcount)(const __m$(bitcount) a){
                const auto b = xs::batch<float,$(bitcount >> 5)>(a);
                xs::batch<float,$(bitcount >> 5)> sb, cb;
                xs::$(f)(b, sb, cb);
                __m$(bitcount) s = sb;
                __m$(bitcount) c = cb;
                return std::make_pair(s,c);
            }
            """
        end
    end
    cxx_code *= "\n}"
    open("xsimdmathfunctions.cpp", "w") do f
        write(f, cxx_code)
    end
end

if isdir("xsimd")
    cd("xsimd")
    run(`git pull`)
    cd("..")
else
    run(`git clone https://github.com/QuantStack/xsimd`)
end

gen_cpp_code()
run(`$(get(ENV,"CXX","g++")) -I./xsimd/include $(split(get(ENV,"CXXFLAGS",""))) -fno-semantic-interposition -march=native -Ofast -shared -fPIC xsimdmathfunctions.cpp -o libxsimdmath.so`)


