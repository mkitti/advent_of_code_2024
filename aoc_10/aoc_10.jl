#!/usr/bin/env -S julia --project
module AdventOfCodeDay10
    function parse_part1(filename::String)
        return stack(readlines(filename), dims=1) .|> (x->parse(Int8, x))
    end

    const steps_p1 = CartesianIndex.((
        ( 1, 0),
        ( 0, 1),
        (-1, 0),
        ( 0,-1)
    ))

    function next_step(map::Matrix{Int8}, loc::CartesianIndex{2}, num::Int8)
        if num == 9
            return [loc]
        end
        trailtails = CartesianIndex{2}[]
        next_num = num + Int8(1)
        for step in steps_p1
            next_loc = loc + step
            #@info "trying next_loc" next_loc
            if checkbounds(Bool, map, next_loc) && map[next_loc] == next_num
                append!(trailtails, next_step(map, next_loc, next_num))
            end
        end
        #@info "next_step" loc num trailtails next_num
        return trailtails
    end

    function part1(filename::String)
        input = parse_part1(filename)
        start_locations = findall(input .== 0)
        s = 0
        for start_location in start_locations
            trailtails = next_step(input, start_location, Int8(0))
            #@info "analysis" start_location trailtails
            s += length(unique(trailtails))
        end
        return s
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        input = parse_part1(filename)
        start_locations = findall(input .== 0)
        s = 0
        for start_location in start_locations
            trailtails = next_step(input, start_location, Int8(0))
            #@info "analysis" start_location trailtails
            s += length(trailtails)
        end
        return s
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
