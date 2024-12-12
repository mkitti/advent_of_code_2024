#!/usr/bin/env -S julia --project
module AdventOfCodeDay12
    function parse_part1(filename::String)
        stack(readlines(filename), dims=2)
    end

    const neighbors = CartesianIndex.((
        (-1 ,0),
        ( 0, 1),
        ( 1, 0),
        ( 0,-1)
    ))

    function get_neighbor_values(label_map, idx)
        values = Int[]
        sizehint!(values, 4)
        for relative in neighbors
            neighbor = idx + relative
            if checkbounds(Bool, label_map, neighbor)
                push!(values, label_map[neighbor])
            else
                push!(values, 0)
            end
        end
        return values
    end


    function connected_components(binary_map)
        label_map = zeros(Int, size(binary_map))
        label = 1
        equivalence = Dict{Int, Set{Int}}()
        # first pass
        for idx in CartesianIndices(binary_map)
            if binary_map[idx] > 0
                neighbor_values = filter(!=(0), get_neighbor_values(label_map, idx))
                if isempty(neighbor_values)
                    label_map[idx] = label
                    label += 1
                else
                    mv = minimum(neighbor_values)
                    label_map[idx] = mv
                    sets = map(neighbor_values) do v
                        s = get(equivalence, v, Set{Int}())
                        equivalence[v] = s
                    end
                    us = union(sets..., neighbor_values)
                    @debug "merging" us neighbor_values
                    for set in sets
                        union!(set, us)
                    end
                end
            end
        end
        #second pass
        for idx in eachindex(label_map)
            if label_map[idx] > 0
                label_map[idx] = haskey(equivalence, label_map[idx]) ? minimum(equivalence[label_map[idx]], init=label_map[idx]) : label_map[idx]
            end
        end
        return label_map
    end

    function area(label_map, label)
        return count(==(label), label_map)
    end
    
    function perimeter(label_map, label)
        perimeter = 0
        for idx in CartesianIndices(label_map)
            if label_map[idx] == label
                if label > 0
                    perimeter += count(!=(label), get_neighbor_values(label_map, idx))
                end
            end
        end
        return perimeter
    end

    function sides(label_map, label)
        dir_map = zeros(Bool, size(label_map)..., 4)
        for idx in CartesianIndices(label_map)
            if label_map[idx] == label
                for (i, relative) in pairs(neighbors)
                    neighbor = idx + relative
                    if !checkbounds(Bool, label_map, neighbor) || label_map[neighbor] != label
                        dir_map[idx, i] = true
                    end
                end
            end
        end
        s = 0
        for n in eachindex(neighbors)
            s += length(filter(!=(0), unique(label_components(dir_map[:,:,n]))))
        end
        return s
    end

    using Images

    function part1(filename::String)
        input = parse_part1(filename)
        uniq_input = unique(input)
        total_price = 0
        for u in uniq_input
            binary_map = u .== input
            lm = label_components(binary_map)
            #lm = connected_components(binary_map)
            #=
            open("$u.txt", "w") do io
                for row in eachrow(lm)
                    println(io, (row .+ 'A')...)
                end
            end
            =#
            for uniq_label in unique(lm)
                if uniq_label > 0
                    a = area(lm, uniq_label)
                    p = perimeter(lm, uniq_label)
                    total_price += a * p
                    @debug "Region" u uniq_label a p
                    # display(lm)
                end
            end
        end
        return total_price
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        input = parse_part1(filename)
        uniq_input = unique(input)
        total_price = 0
        for u in uniq_input
            binary_map = u .== input
            lm = label_components(binary_map)
            #lm = connected_components(binary_map)
            #=
            open("$u.txt", "w") do io
                for row in eachrow(lm)
                    println(io, (row .+ 'A')...)
                end
            end
            =#
            for uniq_label in unique(lm)
                if uniq_label > 0
                    a = area(lm, uniq_label)
                    p = sides(lm, uniq_label)
                    total_price += a * p
                    @debug "Region" u uniq_label a p
                    # display(lm)
                end
            end
        end
        return total_price

    end

    function main()
        #@show part1("demo.txt")
        #@show part1("input.txt")
        #@show part2("demo.txt")
        @show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
