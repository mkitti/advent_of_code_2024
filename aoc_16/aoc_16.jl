#!/usr/bin/env -S julia --project
module AdventOfCodeDay16
    function parse_part1(filename::String)
        stack(readlines(filename), dims=1)
    end

    function display_chars(m::Matrix{Char})
        for row in eachrow(m)
            println(String(row))
        end
    end

    const neighbors = CartesianIndex{2}.([
        (-1, 0),
        ( 0, 1),
        ( 1, 0),
        ( 0,-1)
    ])

    const neighbors_with_turns = CartesianIndex{3}.([
        (-1, 0, 1),
        ( 0, 1, 2),
        ( 1, 0, 3),
        ( 0,-1, 4)
    ])

    const turns = CartesianIndex{3}.([
        ( 0, 0, 0),
        ( 0, 0, 1),
        ( 0, 0, 2),
        ( 0, 0, 3)
    ])


    function distance_map(origin::CartesianIndex{2}, map::Matrix{Char})
        pts = [origin]
        new_pts = CartesianIndex{2}[]
        sizehint!(new_pts, 4)
        distance_map = zeros(Int, size(map))
        for idx in eachindex(map)
            if map[idx] == '#'
                distance_map[idx] = -1
            end
        end
        distance = 1
        while !isempty(pts)
            for pt in pts
                for relative in neighbors
                    neighbor = pt + relative
                    if distance_map[neighbor] == 0 && map[neighbor] ∈ ('.', 'S', 'E')
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
        display(distance_map)
        return distance_map
    end

    function turn_distance_map(origins::Vector{CartesianIndex{3}}, map::Matrix{Char})
        #origin = CartesianIndex{3}(origin[1], origin[2], 2)
        #pts = [origin]
        pts = origins
        new_pts = CartesianIndex{3}[]
        sizehint!(new_pts, 8)
        turn_map = cat(map, map, map, map; dims=3)
        distance_map = zeros(Int, size(turn_map))
        for idx in CartesianIndices(map)
            if map[idx] == '#'
                for turn in 1:4
                    distance_map[idx, turn] = -1
                end
            end
        end
        distance = 1
        while !isempty(pts)
            for pt in pts
                for relative in turns
                    neighbor = pt + relative
                    neighbor = CartesianIndex{3}(neighbor[1], neighbor[2], mod1(neighbor[3], 4))
                    if distance_map[neighbor] >= 0 && turn_map[neighbor] ∈ ('.', 'S', 'E')
                        turn_distance = abs(pt[3] - neighbor[3])
                        turn_distance = min(turn_distance, 4 - turn_distance)
                        turn_distance *= 1000
                        total_distance = distance_map[pt] + turn_distance
                        if distance_map[neighbor] > total_distance || distance_map[neighbor] == 0
                            distance_map[neighbor] = total_distance
                            push!(new_pts, neighbor)
                        end
                    end
                end
                let relative = neighbors_with_turns[pt[3]]
                    neighbor = pt + relative - CartesianIndex(0,0,pt[3])
                    if distance_map[neighbor] >= 0 && turn_map[neighbor] ∈ ('.', 'S', 'E')
                        total_distance = distance_map[pt] + 1
                        if distance_map[neighbor] > total_distance || distance_map[neighbor] == 0
                            distance_map[neighbor] = total_distance
                            push!(new_pts, neighbor)
                        end
                    end
                end
            end
            pts = new_pts
            new_pts = CartesianIndex{3}[]
            sizehint!(new_pts, length(pts)*8)
        end
        for idx in eachindex(distance_map)
            if distance_map[idx] < 1
                distance_map[idx] = typemax(Int) 
                # distance_map[idx] = 9999
            end
        end
        distance_map[origins] .= 0
        #display(distance_map)
        return distance_map
    end


    function part1(filename::String)
        input = parse_part1(filename)
        start_location = findfirst(==('S'), input)
        start_locations = [CartesianIndex{3}(start_location[1], start_location[2], 2)]
        end_location = findfirst(==('E'), input)
        end_locations = map(1:4) do d
            CartesianIndex{3}(end_location[1], end_location[2], d)
        end
        start_dm = turn_distance_map(start_locations, input)
        end_dm = turn_distance_map(end_locations, input)
        sum_dm = start_dm + circshift(end_dm, (0,0,2))
        min_dist = minimum(filter(>(0), sum_dm))
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        input = parse_part1(filename)
        start_location = findfirst(==('S'), input)
        start_locations = [CartesianIndex{3}(start_location[1], start_location[2], 2)]
        end_location = findfirst(==('E'), input)
        end_locations = map(1:4) do d
            CartesianIndex{3}(end_location[1], end_location[2], d)
        end
        start_dm = turn_distance_map(start_locations, input)
        min_dist = typemax(Int)
        sum_dm = nothing
        for end_location in end_locations
            end_dm = turn_distance_map([end_location], input)
            sum_dm_dir = start_dm + circshift(end_dm, (0,0,2))
            min_dist_dir = minimum(filter(>(0), sum_dm_dir))
            if min_dist > min_dist_dir
                min_dist = min_dist_dir
                sum_dm = sum_dm_dir
            end
        end
        count(==(min_dist), minimum(sum_dm; dims=3))
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
