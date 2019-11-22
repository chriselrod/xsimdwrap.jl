
const XSIMD_DICT = Dict(
    (f => (:xsimdwrap, f) for f ∈ float_to_float)...,
    (f => (:xsimdwrap, f) for f ∈ floatfloat_to_float)...,
    (f => (:xsimdwrap, f) for f ∈ float_to_floatfloat)...,
    :^ => (:xsimdwrap, :pow)
)


"""
Arguments are
@xvectorize Type UnrollFactor forloop
The default type is Float64, and default UnrollFactor is 1 (no unrolling).
"""


for gcpreserve ∈ (true,false)
    if gcpreserve
        macroname = :xvectorize
    else
        macroname = Symbol(:xvectorize, :_unsafe)
    end
    @eval macro $macroname(expr)
        if @capture(expr, for n_ ∈ 1:N_ body__ end)
            q = vectorize_body(N, Float64, 1, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(A_) body__ end)
            q = vectorize_body(:(length($A)), Float64, 1, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(args__) body__ end)
            q = vectorize_body(:(min($([:(length($a)) for a ∈ args]...))), Float64, 1, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        else
            throw("Could not match loop expression.")
        end
        esc(q)
    end
    @eval macro $macroname(type, expr)
        if @capture(expr, for n_ ∈ 1:N_ body__ end)
            q = vectorize_body(N, type, 1, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(A_) body__ end)
            q = vectorize_body(:(length($A)), type, 1, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(args__) body__ end)
            q = vectorize_body(:(min($([:(length($a)) for a ∈ args]...))), type, 1, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        else
            throw("Could not match loop expression.")
        end
        esc(q)
    end
    @eval macro $macroname(unroll_factor::Integer, expr)
        if @capture(expr, for n_ ∈ 1:N_ body__ end)
            q = vectorize_body(N, Float64, unroll_factor, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(A_) body__ end)
            q = vectorize_body(:(length($A)), Float64, unroll_factor, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(args__) body__ end)
            q = vectorize_body(:(min($([:(length($a)) for a ∈ args]...))), Float64, unroll_factor, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        else
            throw("Could not match loop expression.")
        end
        esc(q)
    end
    @eval macro $macroname(type, unroll_factor::Integer, expr)
        if @capture(expr, for n_ ∈ 1:N_ body__ end)
            q = vectorize_body(N, type, unroll_factor, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(A_) body__ end)
            q = vectorize_body(:(length($A)), type, unroll_factor, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(args__) body__ end)
            q = vectorize_body(:(min($([:(length($a)) for a ∈ args]...))), type, unroll_factor, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, :xsimdwrap)
        else
            throw("Could not match loop expression.")
        end
        esc(q)
    end
    @eval macro $macroname(type, mod::Union{Symbol,Module}, expr)
        if @capture(expr, for n_ ∈ 1:N_ body__ end)
            q = vectorize_body(N, type, 1, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, mod, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(A_) body__ end)
            q = vectorize_body(:(length($A)), type, 1, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, mod, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(args__) body__ end)
            q = vectorize_body(:(min($([:(length($a)) for a ∈ args]...))), type, 1, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, mod, :xsimdwrap)
        else
            throw("Could not match loop expression.")
        end
        esc(q)
    end
    @eval macro $macroname(type, mod::Union{Symbol,Module}, unroll_factor::Integer, expr)
        if @capture(expr, for n_ ∈ 1:N_ body__ end)
            q = vectorize_body(N, type, unroll_factor, n, body, XSIMD_DICT, SIMDPirates.Vec, mod, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(A_) body__ end)
            q = vectorize_body(:(length($A)), type, unroll_factor, n, body, XSIMD_DICT, SIMDPirates.Vec, mod, :xsimdwrap)
        elseif @capture(expr, for n_ ∈ eachindex(args__) body__ end)
            q = vectorize_body(:(min($([:(length($a)) for a ∈ args]...))), type, unroll_factor, n, body, XSIMD_DICT, SIMDPirates.Vec, $gcpreserve, mod, :xsimdwrap)
        else
            throw("Could not match loop expression.")
        end
        esc(q)
    end
end

