#!/usr/bin/env -S julia --project
module AdventOfCodeDay25
    function parse_part1(filename::String)
        locks = Matrix{Bool}[]
        keys = Matrix{Bool}[]
        temp = Vector{Bool}[]
        islock = true
        for line in eachline(filename)
            if isempty(line)
                obj = stack(temp, dims=1)
                if islock
                    push!(locks, obj)
                else
                    push!(keys, obj)
                end
                empty!(temp)
                continue
            end
            bline = (Vector{Char}(line) .== '#')
            println(bline)
            if isempty(temp)
                # first line
                islock = all(bline)
            end
            push!(temp, bline)
        end
        obj = stack(temp, dims=1)
        if islock
            push!(locks, obj)
        else
            push!(keys, obj)
        end
        return locks, keys
    end

    function part1(filename::String)
        locks, keys = parse_part1(filename)
        lock_heights = map(locks) do lock
            sum(lock, dims=1) .- 1
        end
        key_heights = map(keys) do key
            sum(key, dims=1) .- 1
        end
        count = 0
        for (lock,key) in Iterators.product(lock_heights, key_heights)
            count += all(<(6), (lock .+ key))
        end
        return count
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        input = parse_part1(filename)
    end

    function main()
        @show part1("demo.txt")
        @show part1("input.txt")
        #@show part2("demo.txt")
        #@show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
