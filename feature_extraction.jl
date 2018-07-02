include("distvar_operations.jl")
include("feature_operations.jl")

function add_sample_to_feature_distributions!(feature_distributions::Vector{Vector{Float64}}, chr, startpos, endpos, eventtype)
    i = 1
    for op in feature_ops
        push!(feature_distributions[i], op(chr, startpos, endpos, eventtype))
        i += 1
    end
end

function generate_input_matrix_from_bedfile(file)
    input = readdlm(file, '\t')
    sample_feature_distributions = Dict{String, Vector{Vector{Float64}}}()
    samplecount = 0
    distvar_opcount = size(distvar_ops, 1)
    feature_opcount = size(feature_ops, 1)
    for i = 1:size(input,1)
        samplename = input[i, 7]
        if !haskey(sample_feature_distributions, samplename)
            sample_feature_distributions[samplename] = fill(Vector{Float64}(), feature_opcount)
            samplecount = samplecount + 1
        end
        add_sample_to_feature_distributions!(sample_feature_distributions[samplename], input[i,1], input[i,2], input[i,3], input[i, 4])
    end

    samplecount -= 13 # Discard 13 samples with just one entry in input manually for now
    varcount = distvar_opcount * feature_opcount
    M = Array{Float64}(samplecount, varcount)
    i = 1
    for feature_distributions in values(sample_feature_distributions)
        if size(feature_distributions[1], 1) > 1 # this if discards the samples with one entry
            for j = 1:feature_opcount
                k = feature_opcount*(j-1)
                for dv = 1:distvar_opcount
                    M[i, k+dv] = distvar_ops[dv](feature_distributions[j])
                end
            end
            i += 1
        end
    end
    M ./= maximum(M, 1)
    p("$(samplecount)x$(varcount) matrix generation complete")
    return M
end
