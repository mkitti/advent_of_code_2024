#!/usr/bin/env -S julia --project
module AdventOfCodeDay02
    function parse_part1(filename::String)
        map(eachline(filename)) do line
            map(split(line)) do field
                parse(Int, field)
            end
        end
    end

    function is_safe(input)
        d = diff(input)
        ad = abs.(d)
        if any(>(3), ad)
            @debug "Unsafe" input
            return false
        end
        s = sign.(d)
        unique_diff = unique(s)
        if length(unique_diff) > 1
            @debug "Unsafe" input
            return false
        else
            unique_diff_value = only(unique_diff)
            if unique_diff_value ∈ (-1,1)
                @debug "Safe" input
                return true
            else
                @debug "Unsafe" input
                return false
            end
        end
    end

    function part1(filename::String)
        inputs = parse_part1(filename)
        map(inputs) do input
            is_safe(input)
        end |> sum
    end

    function unsafe_level_change(x,y)
        a = abs(x-y)
        if a > 3 || a < 1
            return true
        end
        return false
    end

    function part2(filename::String)
        inputs = parse_part1(filename)
        map(inputs) do input
            change_sign = sign(input[2] - input[1])
            faults = 0
            fault_idx = 0
            idx = 0
            for (x,y) in zip(input[1:end-1], input[2:end])
                idx += 1
                if sign(y-x) != change_sign || unsafe_level_change(x,y)
                    @debug "Fault" x y change_sign
                    fault_idx = idx
                    faults += 1
                end
                if faults > 1
                    @debug "Unsafe" input
                    return false
                end
            end
            if faults == 1
                new_input = deleteat!(copy(input), fault_idx)
                safe = is_safe(new_input)
                if !safe && fault_idx+1 <= length(input)
                    new_input2 = deleteat!(copy(input), fault_idx+1)
                    safe = is_safe(new_input2)
                end
                if safe
                    @debug "Safe" input
                else
                    @debug "Unsafe" input
                end
                return safe
            end
            @debug "Safe" input
            return true
        end |> sum
    end

    function part2v2(filename::String)
        inputs = parse_part1(filename)
        map(inputs) do input
            if is_safe(input)
                return true
            end
            for idx in 1:length(input)
                new_input = copy(input)
                new_input = deleteat!(new_input, idx)
                if is_safe(new_input)
                    return true
                end
            end
            return false
        end |> sum
    end

    function main()
        # @show part1("demo.txt")
        # @show part1("input.txt")
        # @show part2("demo.txt")
        # @show part2("input.txt")
        @show part2v2("demo.txt")
        @show part2v2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
