include("ref/hg19.jl")

function get_centromere_pos(chr)
    ppos = 0
    for (pos, loc) in ref_cytobands[chr]
        if(loc[1] == 'q')
            return ppos
        end
        ppos = pos
    end
end

function distance_from_centromere(chr, startpos, endpos, eventtype)
    chr = string(chr)
    cpos = get_centromere_pos(chr)
    clen = ref_chromosome_sizes[chr]
    spos = (endpos - startpos) / 2
    arm_length = (cpos > spos) ? cpos : clen - cpos
    return abs(cpos - spos) / arm_length
end

function segment_size(chr, startpos, endpos, eventtype)
    return (endpos - startpos) / 10000000
end

const feature_ops = [segment_size, distance_from_centromere]
