module xsimdwrap

using VectorizationBase
using VectorizationBase: REGISTER_SIZE
using SIMDPirates
using LoopVectorization: vectorize_body
using MacroTools: @capture

export @xvectorize

const xsimdmath = joinpath(@__DIR__, "..", "deps", "libxsimdmath.so");

const float_to_float = [ 
    # "abs", "fabs",
    :exp, :exp2, :exp10, :expm1, :log, :log2, :log10, :log1p,
    :sin, :cos, :tan, :asin, :acos, :atan, 
    :sinh, :cosh, :tanh, :asinh, :acosh, :atanh,
    :erf, :erfc, :tgamma, :lgamma
]
# const float_to_int = [
#     :ceil, :floor, :trunc, :round, :nearbyint, :rint
# ]
const floatfloat_to_float = [
    # "fmod", "remainder", "min", "max", "fmin", "fmax", "fdim",
    :pow, :hypot, :atan2
]
# const floatfloatfloat_to_float = [
#     :clip
# ]
const float_to_floatfloat = [
    :sincos
]
# const float_to_bool = [
#     :isfinite, :isinf, :isnan
# ]


for f ∈ float_to_float
    for bytecount ∈ (16, 32, 64)
        bytecount > REGISTER_SIZE && continue
        W64 = bytecount>>3
        W32 = bytecount>>2
        fname = QuoteNode(Symbol(:xsimd_,f,:_,bytecount<<3))
        dname = QuoteNode(Symbol(:xsimd_,f,:_,bytecount<<3,:d))
        @eval begin
            function $f(x::NTuple{$W64,Core.VecElement{Float64}})
                ccall(
                    ($dname, xsimdmath), NTuple{$W64,Core.VecElement{Float64}}, (NTuple{$W64,Core.VecElement{Float64}},), x
                )
            end
            function $f(x::NTuple{$W32,Core.VecElement{Float32}})
                ccall(
                    ($fname, xsimdmath), NTuple{$W32,Core.VecElement{Float32}}, (NTuple{$W32,Core.VecElement{Float32}},), x
                )
            end
        end
    end
end
for f ∈ floatfloat_to_float
    for bytecount ∈ (16, 32, 64)
        bytecount > REGISTER_SIZE && continue
        W64 = bytecount>>3
        W32 = bytecount>>2
        fname = QuoteNode(Symbol(:xsimd_,f,:_,bytecount<<3))
        dname = QuoteNode(Symbol(:xsimd_,f,:_,bytecount<<3,:d))
        @eval begin
            function $f(x::NTuple{$W64,Core.VecElement{Float64}},y::NTuple{$W64,Core.VecElement{Float64}})
                ccall(
                    ($dname, xsimdmath), NTuple{$W64,Core.VecElement{Float64}},
                    (NTuple{$W64,Core.VecElement{Float64}},NTuple{$W64,Core.VecElement{Float64}}), x, y
                )
            end
            function $f(x::NTuple{$W32,Core.VecElement{Float32}},y::NTuple{$W32,Core.VecElement{Float32}})
                ccall(
                    ($fname, xsimdmath), NTuple{$W32,Core.VecElement{Float32}},
                    (NTuple{$W32,Core.VecElement{Float32}},NTuple{$W32,Core.VecElement{Float32}}), x, y
                )
            end
        end
    end
end
for f ∈ float_to_floatfloat
    for bytecount ∈ (16, 32, 64)
        bytecount > REGISTER_SIZE && continue
        W64 = bytecount>>3
        W32 = bytecount>>2
        fname = QuoteNode(Symbol(:xsimd_,f,:_,bytecount<<3))
        dname = QuoteNode(Symbol(:xsimd_,f,:_,bytecount<<3,:d))
        @eval begin
            function $f(x::NTuple{$W64,Core.VecElement{Float64}})
                ccall(
                    ($dname, xsimdmath), Tuple{NTuple{$W64,Core.VecElement{Float64}},NTuple{$W64,Core.VecElement{Float64}}},
                    (NTuple{$W64,Core.VecElement{Float64}},), x
                )
            end
            function $f(x::NTuple{$W32,Core.VecElement{Float32}})
                ccall(
                    ($fname, xsimdmath), Tuple{NTuple{$W32,Core.VecElement{Float32}},NTuple{$W32,Core.VecElement{Float32}}},
                    (NTuple{$W32,Core.VecElement{Float32}},), x
                )
            end
        end
    end
end


include("vectorize_loops.jl")

end # module
