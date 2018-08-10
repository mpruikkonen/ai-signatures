include("ref/hg19.jl")
include("distvar_operations.jl")

let feature_ops = []
    opnames = []
    print("feature operations in matrix order:")
    for file in filter(x -> endswith(x, ".jl"), readdir("feature_operations"))
        f = include("feature_operations/$file")
        push!(feature_ops, f)
        opname = Base.function_name(f)
        push!(opnames, opname)
        print(" $opname")
    end
    println("")

    global generate_input_matrix_from_bedfile
    function generate_input_matrix_from_bedfile(file)
        input = readdlm(file, '\t')
        sample_dist_data = Dict{String, Vector{Any}}()
        samplecount = 0
        distvar_opcount = size(distvar_ops, 1)
        feature_opcount = size(feature_ops, 1)
        for i = 1:size(input,1)
            samplename = input[i, 7]
            if !haskey(sample_dist_data, samplename)
                sample_dist_data[samplename] = Vector{Any}(feature_opcount)
                for j = 1:feature_opcount
                    sample_dist_data[samplename][j] = feature_ops[j]()
                end
                samplecount += 1
            end
            for j = 1:feature_opcount
                chr = string(input[i, 1])
                sample_dist_data[samplename][j] = feature_ops[j](sample_dist_data[samplename][j], chr, input[i, 2], input[i, 3], input[i, 4])
            end
        end

        varcount = distvar_opcount * feature_opcount
        M = Array{Float64}(samplecount, varcount)
        i = 1
        for (samplename, dist_data) in sample_dist_data
            for j = 1:feature_opcount
                ddist::Vector{Float64} = feature_ops[j](dist_data[j])
                if(length(ddist) < 2)
                    print("$(Base.function_name(feature_ops[j])) produced a ddist with < 2 elements for sample $samplename")
                    quit()
                end
                k = distvar_opcount*(j-1)
                for dv = 1:distvar_opcount
                    M[i, k+dv] = distvar_ops[dv](ddist)
                end
            end
            i += 1
        end
        M ./= maximum(M, 1)
        M .*= 100 # BayesNMF with demo parameters performs poorly with matrices normalized to [0, 1] so scale values
                  # to approximately correspond with the scale of the values in the demo matrix for now
        p("$(samplecount)x$(varcount) matrix generation complete")
        return M, opnames
    end
end
