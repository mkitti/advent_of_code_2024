#!/usr/bin/env -S julia --project
module AdventOfCodeDay20
    function parse_part1(filename::String)
        stack(readlines(filename), dims=1)
    end

    function display_charmap(m::AbstractMatrix)
        for row in eachrow(m)
            println(join(string.(row)))
        end
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

    function count_neighbors(m::AbstractMatrix{Bool})
        neighbor_count_map = zeros(Int, size(m))
        for ci in CartesianIndices(m)
            num_neighbors = 0
            for relative in neighbors
                neighbor = relative + ci
                if checkbounds(Bool, m, neighbor)
                    if m[neighbor]
                        num_neighbors += 1
                    end
                end
            end
            neighbor_count_map[ci] = num_neighbors
        end
        return neighbor_count_map
    end

    function is_cheat_candidate(idx::CartesianIndex, nc_map::AbstractMatrix{Int})
        # ignore border
        if idx[1] == 1 || idx[2] == 1 || idx[1] == size(nc_map, 1) || idx[2] == size(nc_map,2)
            return false
        end
        if nc_map[idx] <= 2  && nc_map[idx] > 0
            return true
        end
        return false
    end

    function part1(filename::String)
        input = parse_part1(filename)
        boolmap = input .== '#'
        nc_map = count_neighbors(boolmap) .* boolmap
        candidate_map = map(CartesianIndices(nc_map)) do ci
            is_cheat_candidate(ci, nc_map)
        end
        candidates = findall(candidate_map)
        start_ci = findfirst(==('S'), input)
        end_ci = findfirst(==('E'), input)
        start_dist = distance_map(start_ci, boolmap)
        end_dist = distance_map(end_ci, boolmap)
        sum_dist = start_dist + end_dist
        min_path_dist = minimum(d-> d <= 0 ? typemax(d) : d, sum_dist)
        min_path_map = sum_dist .!= min_path_dist
        min_path_dist_map = distance_map(start_ci, min_path_map)
        num_cheats = 0
        for candidate in candidates
            map_copy = copy(boolmap)
            map_copy[candidate] = 0
            neighbor_start_dist = map(neighbors) do relative
                neighbor = candidate + relative
                start_dist[neighbor]
            end
            neighbor_sum_dist = map(neighbors) do relative
                neighbor = candidate + relative
                sum_dist[neighbor]
            end
            neighbor_min_path_dist = map(neighbors) do relative
                neighbor = candidate + relative
                min_path_dist_map[neighbor]
            end
            would_skip = false
            if maximum(neighbor_start_dist) - minimum(filter(>(0), neighbor_start_dist)) < 100
                would_skip = true
            end
            start_dist = distance_map(start_ci, map_copy)
            end_dist = distance_map(end_ci, map_copy)
            cheat_min_path_dist = minimum(d-> d <= 0 ? typemax(d) : d, start_dist + end_dist)
            if min_path_dist - cheat_min_path_dist >= 100
                num_cheats += 1
                @info would_skip candidate maximum(neighbor_start_dist) minimum(filter(>(0), neighbor_start_dist)) min_path_dist cheat_min_path_dist maximum(neighbor_sum_dist) minimum(filter(>(0), neighbor_sum_dist)) maximum(neighbor_min_path_dist) minimum(filter(>(0), neighbor_min_path_dist))
            end
            #@info "Cheat" candidate min_path_dist - cheat_min_path_dist
        end
        return num_cheats
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function is_cheat_candidate_part2(S::CartesianIndex, E::CartesianIndex, bool_map::AbstractMatrix{Bool}, start_dist_map::AbstractMatrix{Int}, min_path_dist_map::AbstractMatrix{Int})
        if bool_map[idx] && abs(S[1] - E[1]) + abs(S[2] - E[2]) <= 20
            if abs(start_dist_map[S] - start_dist_map[E]) >= 100
                return true
            end
            if abs(min_path_dist_map[S] - min_path_dist_map[E]) >= 100
                return true
            end
        end
        return false
    end

    function part2v2(filename::String, min_time=100)
        input = parse_part1(filename)
        boolmap = input .== '#'
        start_ci = findfirst(==('S'), input)
        end_ci = findfirst(==('E'), input)
        start_dist = distance_map(start_ci, boolmap)
        end_dist = distance_map(end_ci, boolmap)
        sum_dist = start_dist + end_dist
        min_path_dist = minimum(d-> d <= 0 ? typemax(d) : d, sum_dist)
        min_path_map = sum_dist .!= min_path_dist
        display_charmap(Int.(min_path_map))
        min_path_dist_map = distance_map(start_ci, min_path_map)
        display(min_path_dist_map)
        num_cheats = 0
        cis = CartesianIndices(input)
        savings_hist = zeros(Int, min_path_dist)
        for i in eachindex(input)
            if boolmap[i]
                continue
            end
            if min_path_map[i]
                continue
            end
            for j in eachindex(input)
                if i > j
                    continue
                end
                if boolmap[j]
                    continue
                end
                if min_path_map[j]
                    continue
                end
                S = cis[i]
                E = cis[j]
                SE_dist = abs(S[1] - E[1]) + abs(S[2] - E[2])
                if SE_dist > 20
                    continue
                end
                savings = abs(min_path_dist_map[S] - min_path_dist_map[E]) - SE_dist
                #if savings == 74
                #    @info "74" S E abs(min_path_dist_map[S] - min_path_dist_map[E]) SE_dist
                #end
                if savings >= min_time
                    savings_hist[savings] += 1
                end
            end
        end
        for L in min_time:length(savings_hist)
            println("$L: $(savings_hist[L])")
        end
        return sum(savings_hist)
    end

    function part2(filename::String, min_time=100)
        return part2v2(filename, min_time)
        input = parse_part1(filename)
        boolmap = input .== '#'
        start_ci = findfirst(==('S'), input)
        end_ci = findfirst(==('E'), input)
        start_dist = distance_map(start_ci, boolmap)
        end_dist = distance_map(end_ci, boolmap)
        sum_dist = start_dist + end_dist
        min_path_dist = minimum(d-> d <= 0 ? typemax(d) : d, sum_dist)
        min_path_map = sum_dist .!= min_path_dist
        display_charmap(Int.(min_path_map))
        min_path_dist_map = distance_map(start_ci, min_path_map)
        display(min_path_dist_map)
        return
        num_cheats = 0
        cis = CartesianIndices(input)
        for i in eachindex(input)
            if boolmap[i]
                continue
            end
            if min_path_map[i]
                continue
            end
            for j in eachindex(input)
                if i > j
                    continue
                end
                if boolmap[j]
                    continue
                end
                if min_path_map[j]
                    continue
                end
                S = cis[i]
                E = cis[j]
                if abs(S[1] - E[1]) + abs(S[2] - E[2]) > 19
                    #@info "Exlcuding on pair distance" S E abs(S[1] - E[1]) + abs(S[2] - E[2])
                    continue
                end
                D = E - S
                if boolmap[S[1] + sign(D[1]), S[2]]
                    map_copy = copy(boolmap)
                    for i in 1:abs(D[1])
                        map_copy[S[1] + sign(D[1])*i, S[2]] = false
                    end
                    for i in 1:abs(D[2])
                        map_copy[E[1], S[2] + sign(D[2])*i] = false
                    end
                elseif boolmap[S[1], S[2] + sign(D[2])]
                    map_copy = copy(boolmap)
                    for i in 1:abs(D[2])
                        map_copy[S[1], S[2] + sign(D[2])*i] = false
                    end
                    for i in 1:abs(D[1])
                        map_copy[S[1] + sign(D[1])*i, E[2]] = false
                    end
                else
                    continue
                end
                start_dist = distance_map(start_ci, map_copy)
                end_dist = distance_map(end_ci, map_copy)
                sum_dist = start_dist + end_dist
                cheat_min_path_dist = minimum(d-> d <= 0 ? typemax(d) : d, sum_dist)

                if min_path_dist - cheat_min_path_dist == 76
                    display_charmap(Int.(cheat_min_path_dist .== sum_dist))
                    @info "diff(50)" S E min_path_dist - cheat_min_path_dist
                    continue
                end
    
                #=
                if abs(minimum(filter(>(0), S_neighbor_min_path_dist)) - maximum(filter(>(0), E_neighbor_min_path_dist))) >= min_time
                    #@info "Considering" S E minimum(filter(>(0), S_neighbor_min_path_dist)) minimum(filter(>(0), E_neighbor_min_path_dist)) maximum(S_neighbor_min_path_dist) maximum(E_neighbor_min_path_dist) cheat_min_path_dist - min_path_dist
                    num_cheats += 1
                    continue
                end
                if abs(maximum(filter(>(0), S_neighbor_min_path_dist)) - minimum(filter(>(0), E_neighbor_min_path_dist))) >= min_time
                    #@info "Considering" S E minimum(filter(>(0), S_neighbor_min_path_dist)) minimum(filter(>(0), E_neighbor_min_path_dist)) maximum(S_neighbor_min_path_dist) maximum(E_neighbor_min_path_dist) cheat_min_path_dist - min_path_dist
                    num_cheats += 1
                    continue
                end
                =#


                #@info "Rejected" S E minimum(filter(>(0), S_neighbor_min_path_dist)) minimum(filter(>(0), E_neighbor_min_path_dist)) maximum(S_neighbor_min_path_dist) maximum(E_neighbor_min_path_dist) cheat_min_path_dist - min_path_dist
                #   num_cheats += 1
                #=
                map_copy = copy(boolmap)
                map_copy[candidate] = 0
                neighbor_start_dist = map(neighbors) do relative
                    neighbor = candidate + relative
                    start_dist[neighbor]
                end
                neighbor_sum_dist = map(neighbors) do relative
                    neighbor = candidate + relative
                    sum_dist[neighbor]
                end
                neighbor_min_path_dist = map(neighbors) do relative
                    neighbor = candidate + relative
                    min_path_dist_map[neighbor]
                end
                would_skip = false
                if maximum(neighbor_start_dist) - minimum(filter(>(0), neighbor_start_dist)) < 100
                    would_skip = true
                end
                start_dist = distance_map(start_ci, map_copy)
                end_dist = distance_map(end_ci, map_copy)
                cheat_min_path_dist = minimum(d-> d <= 0 ? typemax(d) : d, start_dist + end_dist)
                if min_path_dist - cheat_min_path_dist >= 100
                    num_cheats += 1
                    if would_skip
                        @info "would_skip" candidate maximum(neighbor_start_dist) minimum(filter(>(0), neighbor_start_dist)) min_path_dist cheat_min_path_dist maximum(neighbor_sum_dist) minimum(filter(>(0), neighbor_sum_dist)) maximum(neighbor_min_path_dist) minimum(filter(>(0), neighbor_min_path_dist))
                    end
                end
                #@info "Cheat" candidate min_path_dist - cheat_min_path_dist
                =#
            end
        end
        return num_cheats
    end

    function main()
        #@show part1("demo.txt")
        #@show part1("input.txt")
        @show part2("demo.txt", 50)
        @show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
