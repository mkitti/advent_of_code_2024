#!/usr/bin/env -S julia --project
module AdventOfCodeDay03
    function parse_part1(filename::String)
    end

    function part1(filename::String)
        input = read(filename, String)
        map(eachmatch(r"mul\((\d+),(\d+)\)", input)) do m
            parse(Int, m.captures[1]) * parse(Int, m.captures[2])
        end |> sum
    end

    function parse_part2(filename::String)
        parse_part1()
    end

    function part2(filename::String)
        input = read(filename, String)
        enabled = true
        s = 0
        for m in eachmatch(r"(mul\((\d+),(\d+)\))|(do\(\))|(don't\(\))", input)
            if m.match == "do()"
                enabled = true
            elseif m.match == "don't()"
                enabled = false
            elseif enabled
                s += parse(Int, m.captures[2]) * parse(Int, m.captures[3])
            end
            # parse(Int, m.captures[1]) * parse(Int, m.captures[2])
        end
        return s
    end

    function main()
        @show part1("demo.txt")
        @show part1("input.txt")
        @show part2("demo2.txt")
        @show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
