# Equivalent to BayesNMF.L1W.L2H in http://dx.doi.org/10.1101/322859
function BayesNMF(V0, n_iter, a0, b0, tol, K)
    eps = 1e-50
    del = 1.0
    V = V0 .- minimum(V0)
    N, M = size(V)
    sqrt_mean_V = sqrt(mean(V))
    W = rand(N, K) .* sqrt_mean_V
    H = rand(K, M) .* sqrt_mean_V
    V_ap = W * H .+ eps
    I_NM = ones(N, M)
    I_NK = ones(N, K)

    C = N + M/2 + a0 - 1
    beta = squeeze(C ./ (sum(W, 1)' + 0.5*sum(H .* H, 2) .+ b0), 2)

    iter = 2
    while del >= tol && iter < n_iter
        B = diagm(beta)
        H .= H .* (W' * (V ./ V_ap) ./ (W' * I_NM .+ B * H .+ eps))
        V_ap .= W * H .+ eps
        W .= W .* ((V ./ V_ap) * H' ./ (I_NM * H' .+ I_NK * B .+ eps))
        prev_beta = beta
        beta = squeeze(C ./ (sum(W, 1)' + 0.5*sum(H .* H, 2) .+ b0), 2)
        V_ap .= W * H .+ eps
        if mod(iter, 100) == 0
            del = maximum(abs.(beta .- prev_beta) ./ prev_beta)
#            V_err = V - V_ap
#            error = sum(V_err .* V_err)
#            like = sum(V .* log.((V .+ eps) ./ (V_ap .+ eps)) .+ V_ap .- V)
#            evid = like + sum((sum(W, 1)' .+ 0.5*sum(H .* H, 2) .+ b0) .* beta .- C .* log.(beta))
#            println("$iter $evid $like $error $del")
        end
        iter += 1
    end
    V_err = V - V_ap
    error = sum(V_err .* V_err)
    like = sum(V .* log.((V .+ eps) ./ (V_ap .+ eps)) .+ V_ap .- V)
    evid = like + sum((sum(W, 1)' .+ 0.5*sum(H .* H, 2) .+ b0) .* beta .- C .* log.(beta))
    lambda = 1 ./ beta
    return (W, H, like, evid, lambda, error)
end

#include("demo_input_matrix.jl")
#(W, H, like, evid, lambda, error) = BayesNMF(demo_input_matrix, 200000, 10, 5, 1e-07, 25)
