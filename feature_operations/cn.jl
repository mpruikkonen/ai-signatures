function cn()
    return Vector{Float64}()
end

function cn(data, chr, startpos, endpos, eventtype)
    push!(data, 2) # segment before this loss/gain, TODO: don't push this if prev_end == startpos?
    if(eventtype == "Gain")
        push!(data, 3)
    else
        push!(data, 1)
    end
    # TODO: push segment at end of chromosome (see segment_size())?
    return data
end

function cn(data)
    return data
end
