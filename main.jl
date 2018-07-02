function p(msg)
    println("""$(Dates.format(now(), "yyyy-mm-ddTHH:MM:SS.sss")) $msg""")
end

if !isdir("out")
    Pkg.add("StatsBase")
    mkdir("out")
    p("Created output directory $(pwd())/out")
end

using StatsBase
include("feature_extraction.jl")

function save_nmf_run_output(idx, ret)
    p("NMF run $idx finished: like = $(ret[3]), evid = $(ret[4]), error = $(ret[6])")
    # TODO: write W & H to disk?
    return ret
end

function aisig(datafile; nmf_runs = 1, host = "")
    p("Generating input matrix from data file...")
    M = generate_input_matrix_from_bedfile(datafile)

    if nmf_runs != 1 || host != ""
        # if we're running in a REPL with existing workers we just add
        # an appropriate number of extra (local or remote) processes
        wcount = nprocs() - 1
        if nmf_runs > wcount
            if host != ""
                addprocs([(host, nmf_runs - wcount)], tunnel=true)
            else
                addprocs(nmf_runs - wcount)
            end
        end
    end

    @everywhere include("BayesNMF.jl")

    p("""Dispatching $nmf_runs NMF run$((nmf_runs > 1) ? "s" : "") to worker processes""")
    responses = Vector{Any}(nmf_runs)
    @sync begin
        for (idx, pid) in enumerate(workers())
            if idx <= nmf_runs
                @async responses[idx] = save_nmf_run_output(idx, remotecall_fetch(BayesNMF, pid, M, 200000, 10, 5, 1e-07, 25))
            else
                break
            end
        end
    end
    p("Done")
    return responses
end
