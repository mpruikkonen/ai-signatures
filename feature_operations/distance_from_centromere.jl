function get_centromere_pos(chr)
    ppos = 0
    for (pos, loc) in ref_cytobands[chr]
        if(loc[1] == 'q')
            return ppos
        end
        ppos = pos
    end
end

function push_distance!(data, cpos, clen, pos)
    arm_length = (cpos > pos) ? cpos : clen - cpos
    push!(data, abs(cpos - pos) / arm_length)
end

function distance_from_centromere()
    return Vector{Float64}()
end

function distance_from_centromere(data, chr, startpos, endpos, eventtype)
    cpos = get_centromere_pos(chr)
    clen = ref_chromosome_sizes[chr]
    push_distance!(data, cpos, clen, startpos)
    push_distance!(data, cpos, clen, endpos)
    return data
end

function distance_from_centromere(data)
    return data
end
