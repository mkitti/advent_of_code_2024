#!/usr/bin/env -S julia --project
module AdventOfCodeDayXX
    function parse_part1(filename::String)
        for line in eachline(filename)
        end
    end

    function part1(filename::String)
        input = parse_part1(filename)
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
        @show part2("demo.txt")
        @show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
