#!/usr/bin/env -S julia --project
module AdventOfCodeDay13
    function parse_part1(filename::String)
        machines = Matrix{Int}[]
        machine = zeros(Int, 2, 3)
        i = 1
        regex = r"X[\+\=](\d+), Y[\+\=](\d+)"
        for line in eachline(filename)
            if isempty(line)
                push!(machines, machine)
                machine = zeros(Int, 2, 3)
                i = 1
            else
                m = match(regex, line)
                machine[1, i] = parse(Int, m.captures[1])
                machine[2, i] = parse(Int, m.captures[2])
                i += 1
            end
        end
        push!(machines, machine)
        return machines
    end

    function part1(filename::String)
        machines = parse_part1(filename)
        tokens = 0
        for machine in machines
            L = @view(machine[1:2,1:2])
            R = @view(machine[1:2,3])
            Z = round.(Int, L\R)
            if L * Z == R
                tokens += only([3 1] * Z)
            end
        end
        return tokens
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        machines = parse_part1(filename)
        tokens = 0
        for machine in machines
            L = @view(machine[1:2,1:2])
            R = @view(machine[1:2,3]) .+ 10000000000000
            Z = round.(Int, L\R)
            if L * Z == R
                tokens += only([3 1] * Z)
            end
        end
        return tokens

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
