#!/usr/bin/env -S julia --project
module AdventOfCodeDay08
    function parse_part1(filename::String)
        map(eachline(filename)) do line
            line
        end |> x->stack(x, dims=1)
    end

    function part1(filename::String)
        input = parse_part1(filename)
        input_sz = size(input)
        freqs = filter(!=('.'), unique(input))
        nodes = CartesianIndex{2}[]
        for freq in freqs
            locs = findall(input .== freq)
            for (x,y) in Iterators.product(locs, locs)
                if x == y
                    continue
                end
                d = x - y
                a = x + d
                b = y - d
                if checkbounds(Bool, input, a)
                    push!(nodes, a)
                    @debug "Inbounds: " freq a
                end
                if checkbounds(Bool, input, b)
                    push!(nodes, b)
                    @debug "Inbounds: " freq b
                end
            end
        end
        return length(unique(nodes))
    end

    function part2(filename::String)
        input = parse_part1(filename)
        input_sz = size(input)
        freqs = filter(!=('.'), unique(input))
        nodes = CartesianIndex{2}[]
        for freq in freqs
            locs = findall(input .== freq)
            append!(nodes, locs)
            for (x,y) in Iterators.product(locs, locs)
                if x == y
                    continue
                end
                d = x - y
                a = x + d
                b = y - d
                while checkbounds(Bool, input, a)
                    push!(nodes, a)
                    @debug "Inbounds: " freq a
                    a += d
                end
                while checkbounds(Bool, input, b)
                    push!(nodes, b)
                    @debug "Inbounds: " freq b
                    b -= d
                end
            end
        end
        return length(unique(nodes))
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
