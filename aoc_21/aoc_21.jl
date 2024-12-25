#!/usr/bin/env -S julia --project
module AdventOfCodeDay21
    function parse_part1(filename::String)
        readlines(filename)
    end

    const numpad = [
        '7' '8' '9'
        '4' '5' '6'
        '1' '2' '3'
        ' ' '0' 'A'
    ]

    const numpad_gap = findfirst(==(' '), numpad)
    const numpad_A = findfirst(==('A'), numpad)

    const dpad = [
        ' ' '^' 'A'
        '<' 'v' '>'
    ]
    const dpad_gap = findfirst(==(' '), dpad)
    const dpad_A = findfirst(==('A'), dpad)

    const numpad_cache = Dict{Tuple{Char,CartesianIndex{2}}, Vector{String}}()
    const dpad_cache = Dict{Tuple{Char,CartesianIndex{2}}, Vector{String}}()

    # Simple attempt tries to left right first then up and down
    function pad_sequence_simple(
        code::AbstractString,
        S::CartesianIndex{2}, 
        pad::Matrix{Char},
        pad_gap::CartesianIndex{2}
    )
        c = first(code)
        E = findfirst(==(c), pad)
        keys = pad_sequence_simple(c, S, pad, pad_gap)
        if length(code) == 1
            return keys
        else
            return keys * pad_sequence_simple(@view(code[2:end]), E, pad, pad_gap)
            #=
            return prod.(Iterators.product(
                keys,
                pad_sequence_simple(@view(code[2:end]), E, pad, pad_gap)
            )) |> vec
            =#
        end
    end

    function pad_sequence_simple(
        c::Char,
        S::CartesianIndex{2},
        pad::Matrix{Char},
        pad_gap::CartesianIndex{2} = pad == numpad ? numpad_gap : pad == dpad ? dpad_gap : error("Unknown pad")
    )
        E = findfirst(==(c), pad)
        D = E - S
        # Find permutations of horizontal and vertical movement
        ud = abs(D[1]) 
        lr = abs(D[2])
        N = ud + lr
        pos = S
        chars = Vector{Char}(undef, N+1)
        chars[N+1] = 'A'
        if N == 0
            return String(chars)
        end
        candidates = String[]
        # First try going left and right first
        for i in 1:N
            if i > lr
                s = sign(D[1])
                pos += CartesianIndex(s, 0)
                chars[i] = s == 1 ? 'v' : '^'
            else
                s = sign(D[2])
                pos += CartesianIndex(0, s)
                chars[i] = s == 1 ? '>' : '<'
            end
            #@info "lr" pos S E i N
            if pos == pad_gap
                # we hit the pad gap going this way...
                break
            end
            if i == N
                push!(candidates, String(chars))
            end
        end

        # Try going up and down
        pos = S
        for i in 1:N
            if i <= ud
                s = sign(D[1])
                pos += CartesianIndex(s, 0)
                chars[i] = s == 1 ? 'v' : '^'
            else
                s = sign(D[2])
                pos += CartesianIndex(0, s)
                chars[i] = s == 1 ? '>' : '<'
            end
            #@info "ud" pos S E i N
            if pos == pad_gap
                break
            end
            if i == N
                push!(candidates, String(chars))
            end
        end
        candidates = unique(candidates)
        if length(candidates) == 1
            return only(candidates)
        elseif length(candidates) == 2
            if D[1] < 0 && D[2] < 0 #up-left
                return candidates[1]
            elseif D[1] > 0 && D[2] < 0 #down-left
                return candidates[1]
            elseif D[1] > 0 && D[2] > 0 #down-right
                return candidates[2]
            elseif D[1] < 0 && D[2] > 0 #up-right
                return candidates[2]
            end
            @error "how?" D candidates
            error("Can we get here?")
        else
            error("No candidates!")
        end
    end

    function numpad_sequence_simple(
        code::AbstractString,
        S::CartesianIndex{2} = numpad_A
    )
        return pad_sequence_simple(code, S, numpad, numpad_gap)
    end

    function dpad_sequence_simple(
        code::AbstractString,
        S::CartesianIndex{2} = dpad_A
    )
        return pad_sequence_simple(code, S, dpad, dpad_gap)
    end

    function pad_sequence(
        code::AbstractString,
        S::CartesianIndex{2}, 
        pad::Matrix{Char},
        pad_gap::CartesianIndex{2}
    )
        c = first(code)
        E = findfirst(==(c), pad)
        keys = pad_sequence(c, S, pad, pad_gap)
        if length(code) == 1
            return keys
        else
            return prod.(Iterators.product(
                keys,
                pad_sequence(@view(code[2:end]), E, pad, pad_gap)
            )) |> vec
        end
    end

    # My initial attempt involved trying all permutations
    function pad_sequence(
        c::Char,
        S::CartesianIndex{2},
        pad::Matrix{Char},
        pad_gap::CartesianIndex{2} = pad == numpad ? numpad_gap : pad == dpad ? dpad_gap : error("Unknown pad")
    )
        cache = pad == numpad ? numpad_cache : pad == dpad ? dpad_cache : error("Unknown pad")
        key = (c, S)
        if haskey(cache, key)
            return cache[key]
        end
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
        cache[key] = keys
        return keys
    end

    function numpad_sequence(
        code::AbstractString,
        S::CartesianIndex{2} = numpad_A
    )
        return pad_sequence(code, S, numpad, numpad_gap)
    end

    function dpad_sequence(
        code::AbstractString,
        S::CartesianIndex{2} = dpad_A
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

    const split_A_cache = Dict{String, String}()

    const dpad_select = Dict(
        '<' => "v<<A",
        '>' => "vA",
        '^' => "<A",
        'v' => "v<A",
        'A' => "A"
    )

    function dpad_sequence_min(code::AbstractString)
        keys = dpad_sequence(code)
        keys2 = dpad_sequence.(keys)
        lengths2 = map(keys2) do key2
            length.(key2)
        end
        minimum(Iterators.flatten(lengths2))
        minimum(length, Iterators.flatten(keys2))
        _, idx = findmin(keys) do key
            keys2 = dpad_sequence(key)
            minimum(length, keys2)
        end
        key = keys[idx]
        return key
    end

    function numpad_sequence_min(code::AbstractString)
        argmin(numpad_sequence(code)) do s
           length(dpad_sequence_min(s))
        end
    end

    const split_A_depth_cache = Dict{Tuple{String, Int}, Int}()

    function dpad_sequence_split_A(code::AbstractString, depth=25)
        #if haskey(split_A_cache, code)
        #    return split_A_cache[code]
        #end
        depth_cache_key = (String(code), depth)
        if haskey(split_A_depth_cache, depth_cache_key)
            return split_A_depth_cache[depth_cache_key]
        end
        fullseq = String[]
        min_code_length = 0
        for seq in split(code, 'A')[1:end-1]
            seq = seq * 'A'
            if haskey(split_A_cache, seq)
                key = split_A_cache[seq]
            else
                key = dpad_sequence_simple(seq)
                split_A_cache[seq] = key
            end
            if depth == 0
                key_length = length(key)
            else
                key_length = dpad_sequence_split_A(key, depth - 1)
            end
            min_code_length += key_length
            # push!(fullseq, key)
            #@info seq key
        end
        split_A_depth_cache[depth_cache_key] = min_code_length
        return min_code_length
        #@info "dpad_sequence_split_A" code split(code, 'A') fullseq
        nextcode = prod(fullseq)
        #split_A_cache[code] = nextcode
        return nextcode
    end

    const dpad_to_ci = Dict(
        '>' => CartesianIndex( 0, 1),
        '<' => CartesianIndex( 0,-1),
        '^' => CartesianIndex(-1, 0),
        'v' => CartesianIndex( 1, 0)
    )


    function dpad_to_dpad_forward(code::AbstractString)
        chars = Char[]
        pos = dpad_A
        for c in code
            if c == 'A'
                push!(chars, dpad[pos])
                #@show dpad[pos]
                continue
            end
            #@show pos c dpad_to_ci[c]
            pos += dpad_to_ci[c]
        end
        return String(chars)
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        input = parse_part1(filename)
        score = 0
        for code in input
            #=
            _npseq = numpad_sequence(code)
            @info "Code" code _npseq
            min_length, idx = findmin(_npseq) do seq
                dpad_code = dpad_sequence_split_A(seq)
                length(dpad_code)
            end
            dpad_code = _npseq[idx]
            @info "Min Length" code _npseq min_length dpad_code dpad_sequence_split_A(dpad_code) dpad_sequence_split_A(dpad_sequence_split_A(dpad_code))
            =#
            _npseq = numpad_sequence_simple(code)
            min_length = dpad_sequence_split_A(_npseq, 24)
            num_code = parse(Int, code[1:end-1])
            score += min_length * num_code
            #=
            for seq2 in splits
                @show out1 = prod(seq2)
                @show dpad_to_dpad_forward(out1)
                splits2 = dpad_sequence_split_A(out1, 24)
                #=
                for seq3 in splits2
                    @show out2 = prod(seq3)
                    @show dpad_to_dpad_forward(out2)
                    @show dpad_to_dpad_forward(dpad_to_dpad_forward(out2))
                end
                =#
                @show min_code = argmin(length, prod.(splits2))
                @show dpad_to_dpad_forward(min_code)
            end
            _dpadseqs = map(_npseq) do seq
                splits = dpad_sequence_split_A(seq, 24)
                argmin(length, map(splits) do seq2
                    out1 = prod(seq2)
                    splits2 = dpad_sequence_split_A(out1, 24)
                    min_code = argmin(length, prod.(splits2))
                end)
            end
            @show _dpadseqs
            @show min_code = argmin(length, _dpadseqs)
            @show length(min_code)
            @show dpad_to_dpad_forward(min_code)
            for (k,v) in split_A_cache
                println("$k: $v")
            end
            return
            min_length = minimum(length, _dpadseqs)
            num_code = parse(Int, code[1:end-1])
            score += min_length * num_code
            =#
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
