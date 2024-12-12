#!/usr/bin/env -S julia --project -t auto
module AdventOfCodeDay11
    function parse_part1(filename::String)
        parse.(Int, split(readline(filename)))
    end

    function simulate(stones)
        new_stones = Int[]
        sizehint!(new_stones, length(stones)*2)
        for stone in stones
            if stone == 0
                push!(new_stones, 1)
            elseif length(string(stone)) % 2 == 0
                n_digits = floor(log10(stone)+1)
                tenpow = 10^(n_digits÷2)
                push!(new_stones, stone ÷ tenpow)
                push!(new_stones, stone % tenpow)
            else
                push!(new_stones, stone*2024)
            end
        end
        return new_stones
    end

    const cache = Dict{Int, Vector{Int}}()

    function blink25(stones::Int)
        if haskey(cache, stones)
            return cache[stones]
        else
            cache[stones] = blink25([stones])
            return cache[stones]
        end
    end

    function blink25(stones)
        for i in 1:25
            stones = simulate(stones)
        end
        return stones
    end

    function part1(filename::String)
        stones = parse_part1(filename)
        stones = blink25(stones)
        return length(stones)
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        stones_1 = parse_part1(filename)
        s = zeros(Int, length(stones_1))
        Threads.@threads for i in eachindex(stones_1)
            stone_1 = stones_1[i]
            stones_2 = blink25(stone_1)
            for stone_2 in stones_2
                stones_3 = blink25(stone_2)
                for stone_3 in stones_3
                    stones_4 = blink25(stone_3)
                    s[i] += length(stones_4)
                end
            end
        end
        return sum(s)
    end

    function main()
        @show part1("demo.txt")
        @show part1("input.txt")
        @show part2("demo.txt")
        @show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
