# This feature operation currently assumes that the input file is grouped by chromosome
# and sorted by breakpoint position within chromosomes so that we can track previous
# ai segment just by prev_end

const seg_scale = 10000000

function segment_size()
    return ("1", 0, Vector{Float64}())
end

function segment_size(data, chr, startpos, endpos, eventtype)
    prev_end = data[2]
    seg_sizes = data[3]
    if data[1] != chr # new chromosome
        if prev_end != 0
            push!(seg_sizes, (ref_chromosome_sizes[chr] - prev_end) / seg_scale)
            prev_end = 0
        end
    end
    if prev_end < startpos
       push!(seg_sizes, (startpos - prev_end) / seg_scale)
    elseif prev_end > startpos
        p("segment_size: ai segments overlap: $prev_end >= $startpos in chromosome $chr")
        quit()
    end
    push!(seg_sizes, (endpos - startpos) / seg_scale)
    return (chr, endpos, seg_sizes)
end

function segment_size(data)
    chr = data[1]
    prev_end = data[2]
    seg_sizes = data[3]
    if prev_end != 0
        push!(seg_sizes, (ref_chromosome_sizes[chr] - prev_end) / seg_scale)
        prev_end = 0
    end
    # TODO: do we want to add chromosomes with no breaks as long segments?
    return seg_sizes
end
