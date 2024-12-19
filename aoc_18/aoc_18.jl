#!/usr/bin/env -S julia --project
module AdventOfCodeDay18
    function parse_part1(filename::String)
        coordinates = CartesianIndex{2}[]
        for line in eachline(filename)
            push!(coordinates, CartesianIndex(parse.(Int, split(line,','))...))
        end
        return coordinates
    end

    const neighbors = CartesianIndex{2}.([
        (-1, 0),
        ( 0, 1),
        ( 1, 0),
        ( 0,-1)
    ])

    function distance_map(origin::CartesianIndex{2}, map::AbstractMatrix{Bool})
        pts = [origin]
        new_pts = CartesianIndex{2}[]
        sizehint!(new_pts, 4)
        distance_map = zeros(Int, size(map))
        for idx in eachindex(map)
            if map[idx] # wall
                distance_map[idx] = -1
            end
        end
        distance = 1
        while !isempty(pts)
            for pt in pts
                for relative in neighbors
                    neighbor = pt + relative
                    if checkbounds(Bool, map, neighbor) &&
                       distance_map[neighbor] == 0 &&
                       !map[neighbor]
                        distance_map[neighbor] = distance
                        push!(new_pts, neighbor)
                    end
                end
            end
            pts = new_pts
            new_pts = CartesianIndex{2}[]
            sizehint!(new_pts, length(pts)*4)
            distance += 1
        end
        distance_map[origin] = 0
        return distance_map
    end

    function part1(filename::String, sz = (71,71), nbytes = 1024)
        coordinates = parse_part1(filename)
        boolmap = falses(sz)
        num = 0
        for c in coordinates
            boolmap[c + CartesianIndex(1,1)] = true
            num += 1
            if num >= nbytes
                break
            end
        end
        start_map = distance_map(CartesianIndex(1,1), boolmap)
        end_map = distance_map(CartesianIndex(sz), boolmap)
        sum_map = start_map + end_map
        return minimum(filter(>(0), sum_map))
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String, sz = (71,71))
        coordinates = parse_part1(filename)
        boolmap = falses(sz)
        coordinate = nothing
        for c in coordinates
            boolmap[c + CartesianIndex(1,1)] = true
            start_map = distance_map(CartesianIndex(1,1), boolmap)
            end_map = distance_map(CartesianIndex(sz), boolmap)
            sum_map = start_map + end_map
            if sum_map[1,1] == 0
                coordinate = c
                break
            end
        end
        return coordinate
        # return minimum(filter(>(0), sum_map))
    end

    function main()
        @show part1("demo.txt", (7,7), 12)
        @show part1("input.txt", (71, 71), 1024)
        @show part1("demo.txt", (7,7), 25)
        @show part2("demo.txt", (7,7))
        @show part2("input.txt", (71,71))
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
