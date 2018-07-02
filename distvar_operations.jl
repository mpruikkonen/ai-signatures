if !isfile("dip.so")
    run(`gcc -fPIC -O2 -shared -o dip.so dip.c`)
end

function hartigans_dip_test(X::Array{Float64})
    sort!(X)
    n = length(X)
    xlen = Ref{Cint}(n)
    dip = Ref{Cdouble}(1)
    lo_hi = Array{Cint}(4)
    ifault = Ref{Cint}(1)
    gcm = Array{Cint}(n)
    lcm = Array{Cint}(n)
    mn = Array{Cint}(n)
    mj = Array{Cint}(n)
    min_is_0 = Ref{Cint}(0)
    debug = Ref{Cint}(0)
    ccall((:diptst, "./dip.so"), Void,
          (Ptr{Float64}, Ref{Cint}, Ref{Cdouble}, Ptr{Cint}, Ref{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ref{Cint}, Ref{Cint}),
          X, xlen, dip, lo_hi, ifault, gcm, lcm, mn, mj, min_is_0, debug)
    return dip[]
end

function skew(X::Array{Float64})
    abs(skewness(X))
end

function kurt(X::Array{Float64})
    kurtosis(X)+3 # StatBase's kurtosis subtracts 3 from the result to get "excess kurtosis", but we want just positive results?
end

distvar_ops = [mean, var, skewness, kurtosis, hartigans_dip_test]
