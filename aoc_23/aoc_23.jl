#!/usr/bin/env -S julia --project
module AdventOfCodeDay23
    function parse_part1(filename::String)
        d = Dict{String, Set{String}}()
        for line in eachline(filename)
            a, b = split(line, "-")
            d[a] = push!(get(d, a, Set{String}()), b)
            d[b] = push!(get(d, b, Set{String}()), a)
        end
        return d
    end

    function part1(filename::String)
        d = parse_part1(filename)
        triplets = Set{String}[]
        for (k,v) in d
            for k2 in v
                for k3 in intersect(v, d[k2])
                    push!(triplets, Set((k, k2, k3)))
                end
            end
        end
        count(unique(triplets)) do triplet
            any(startswith('t'), triplet)
        end
    end

    function grow_clique(clique::Set{String}, d::Dict{String, Set{String}})
        clique_v = collect(clique)
        common = copy(d[first(clique)])
        for c in clique_v[2:end]
            intersect!(common, d[c])
        end
        if isempty(common)
            return clique
        else
            return push!(copy(clique), first(common))
        end
        # return union(intersect(getindex.((d,), clique)...), clique)
    end

    function isclique(clique::Set{String}, d)
        for c1 in clique
            for c2 in clique
                if c1 == c2
                    continue
                end
                if c2 ∉ d[c1]
                    return false
                end
            end
        end
        return true
    end


    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        d = parse_part1(filename)
        cliques = Set{String}[]
        for (k,v) in d
            for k2 in v
                s = Set((k, k2))
                new_s = grow_clique(s, d)
                while s != new_s
                    s = new_s
                    new_s = grow_clique(s, d)
                end
                push!(cliques, s)
            end
        end
        # cliques = filter(x->isclique(x, d), cliques)
        max_clique = argmax(length, cliques)
        join(sort(collect(max_clique)), ',')
    end

    function main()
        # @show part1("demo.txt")
        # @show part1("input.txt")
        @show part2("demo.txt")
        @show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
