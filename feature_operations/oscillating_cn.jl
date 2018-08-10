function oscillating_cn()
    return ("0", 2, -1, Vector{Float64}())
end

function oscillating_cn(data, chr, startpos, endpos, eventtype)
    (prev_chr, prev_cn, prev_len, chainlengths) = data
    if chr != prev_chr
        prev_cn = 2
        push!(chainlengths, 0)
        prev_len = -1
    end
    cn = eventtype == "Gain" ? 3 : 1
    if cn == prev_cn
        push!(chainlengths, prev_len+1)
        push!(chainlengths, prev_len+2)
        prev_len += 2
    else
        push!(chainlengths, 0)
        push!(chainlengths, 1)
        prev_len = 1
    end
    return (chr, cn, prev_len, chainlengths)
end

function oscillating_cn(data)
    return data[4]
end
