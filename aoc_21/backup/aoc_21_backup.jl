#!/usr/bin/env -S julia --project
module AdventOfCodeDay21
    function parse_part1(filename::String)
        readlines(filename)
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


    const numpad = [
        '7' '8' '9'
        '4' '5' '6'
        '1' '2' '3'
        ' ' '0' 'A'
    ]

    const numpad_gap = findfirst(==(' '), numpad)

    const dpad = [
        ' ' '^' 'A'
        '<' 'v' '>'
    ]
    const dpad_gap = findfirst(==(' '), dpad)

    function pad_sequence(
        code::AbstractString,
        S::CartesianIndex{2}, 
        pad::Matrix{Char},
        pad_gap::CartesianIndex{2}
    )
        c = first(code)
        E = findfirst(==(c), pad)
        D = E - S
        # Find permutations of horizontal and vertical movement
        ud = abs(D[1]) 
        lr = abs(D[2])
        N = ud + lr
        num_permutations = factorial(N)/factorial(ud)/factorial(lr)
        perms = map(0:2^N-1) do n
            digits(n, base=2, pad=N)
        end
        perms = filter(perms) do p
            sum(p) == lr
        end
        perms = filter(perms) do p
            pos = S
            for d in p
                move = d == 0 ?
                    CartesianIndex(sign(D[1]), 0) :
                    CartesianIndex(0, sign(D[2]))
                pos += move
                if pos == pad_gap
                    return false
                end
            end
            return true
        end
        keys = map(perms) do p
            chars = Vector{Char}(undef, length(p)+1)
            i = 1
            for d in p
                if d == 0
                    # ud
                    chars[i] = sign(D[1]) == -1 ? '^' : 'v'
                else
                    # lr
                    chars[i] = sign(D[2]) == -1 ? '<' : '>'
                end
                i += 1
            end
            chars[length(p)+1] = 'A'
            @debug "p to chars" p chars
            String(chars)
        end
        if length(code) == 1
            return keys
        else
            return prod.(Iterators.product(
                keys,
                pad_sequence(@view(code[2:end]), E, pad, pad_gap)
            )) |> vec
        end
    end

    function numpad_sequence(
        code::AbstractString,
        S::CartesianIndex{2} = findfirst(==('A'), numpad)
    )
        return pad_sequence(code, S, numpad, numpad_gap)
    end

    function dpad_sequence(
        code::AbstractString,
        S::CartesianIndex{2} = findfirst(==('A'), dpad)
    )
        return pad_sequence(code, S, dpad, dpad_gap)
    end

    function part1(filename::String)
        input = parse_part1(filename)
        score = 0
        for code in input
            _npseq = numpad_sequence(code)
            _dseq1 = dpad_sequence.(_npseq)
            _dseq2 = dpad_sequence.(Iterators.flatten(_dseq1))
            min_length = minimum(length, Iterators.flatten(_dseq2))
            # _dseq1 = dpad_sequence(argmin(length, _npseq))
            # _dseq2 = dpad_sequence(argmin(length, _dseq1))
            # min_length = minimum(length, _dseq2)
            num_code = parse(Int, code[1:end-1])
            score += min_length * num_code
        end
        return score
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        input = parse_part1(filename)
        score = 0
        for code in input
            _npseq = numpad_sequence(code)
            _dseq1 = dpad_sequence.(_npseq)
            return _dseq1
            _dseq2 = dpad_sequence.(Iterators.flatten(_dseq1))
            min_length = minimum(length, Iterators.flatten(_dseq2))
            num_code = parse(Int, code[1:end-1])
            score += min_length * num_code
        end
        return score
    end

    function main()
        # @show part1("demo.txt")
        # @show part1("input.txt")
        @show part2("demo.txt")
        #@show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
