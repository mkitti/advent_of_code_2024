#!/usr/bin/env -S julia --project
module AdventOfCodeDayXX
    function parse_part1(filename::String)
    end

    function part1(filename::String)
    end

    function parse_part2(filename::String)
        parse_part1()
    end

    function part2(filename::String)
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
