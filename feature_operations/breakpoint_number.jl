function breakpoint_number()
    return Dict{String, Vector{Int}}()
end

function breakpoint_number(data, chr, startpos, endpos, eventtype)
    if(!haskey(data, chr))
        data[chr] = Vector{Int}()
    end
    push!(data[chr], startpos)
    push!(data[chr], endpos)
    return data
end

function breakpoint_number(data)
    ddist = Vector{Float64}()
    window = 10000000
    step = 10000000
    for (chr, breakpoints) in data
        window_start = 0
        window_end = window
        while true
            count = 0
            for bp in breakpoints
                if bp >= window_start && bp < window_end
                    count += 1
                end
            end
            push!(ddist, count)
            if window_end >= ref_chromosome_sizes[chr]
                break
            end
            window_start += step
            window_end += step
        end
    end
    # TODO: add chromosomes without breakpoints?
    return ddist
end
