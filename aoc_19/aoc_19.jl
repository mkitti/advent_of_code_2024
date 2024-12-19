#!/usr/bin/env -S julia --project
module AdventOfCodeDay19
    using Logging
    function parse_part1(filename::String)
        towels = nothing
        patterns = String[]
        for line in eachline(filename)
            if isempty(line)
                @assert !isnothing(towels)
                continue
            end
            if isnothing(towels)
                towels = split(line, ", ")
                continue
            end
            push!(patterns, line)
        end
        return towels, patterns
    end

    function ispossible(pattern, towels::Array{<: AbstractString})
        if isempty(pattern)
            return true
        end
        for towel in towels
            if startswith(pattern, towel)
                @debug "startswith" pattern towel
                if ispossible(
                    @view(pattern[length(towel)+1:end]),
                    towels
                )
                    return true
                end
            end
        end
        return false
    end
    
    const cache = Dict{String,BigInt}()

    function numpossible(pattern, towels::Array{<: AbstractString}, usecache::Bool = true)
        if isempty(pattern)
            return BigInt(1)
        end
        if usecache && haskey(cache, pattern)
            return cache[pattern]
        end
        num = BigInt(0)
        for towel in towels
            if startswith(pattern, towel)
                num += numpossible(
                    @view(pattern[length(towel)+1:end]),
                    towels,
                    usecache
                )
                @debug "numpossible" pattern towel num
            end
        end
        cache[pattern] = num
        return num
    end

    function part1(filename::String)
        towels, patterns = parse_part1(filename)
        num_possible = 0
        for pattern in patterns
            num_possible += ispossible(pattern, towels)
        end
        return num_possible
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String, usecache = true)
        towels, patterns = parse_part1(filename)
        num_possible = 0
        for pattern in patterns
            N = numpossible(pattern, towels, usecache)
            num_possible += N
        end
        # Bug fix, running demo.txt should not influence input.txt
        empty!(cache)
        return num_possible
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
