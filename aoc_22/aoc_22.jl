#!/usr/bin/env -S julia --project
module AdventOfCodeDay22
    function parse_part1(filename::String)
        nums = Int[]
        for line in eachline(filename)
            push!(nums, parse(Int, line))
        end
        return nums
    end

    function mix_and_prune(result, num)
        xor(result, num) % 16777216
    end

    function evolve(num)
        num = mix_and_prune(num*64, num)
        num = mix_and_prune(div(num, 32, RoundDown), num)
        num = mix_and_prune(num*2048, num)
        return num
    end

    function evolve2000(num)
        for i in 1:2000
            num = evolve(num)
        end
        return num
    end

    function evolve2000seq(num)
        out = zeros(Int, 2001)
        out[1] = num
        for i in 1:2000
            out[i+1] = evolve(out[i])
        end
        return out
    end

    function part1(filename::String)
        nums = parse_part1(filename)
        sum(evolve2000.(nums))
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        nums = parse_part1(filename)
        seqs = evolve2000seq.(nums)
        delta_to_prices = Dict{NTuple{4,Int8}, Int}()
        for seq in seqs
            prices = seq .% 10
            diff_prices = Int8.(diff(prices))
            delta_to_prices_seq = Dict{NTuple{4,Int8}, Int}()
            for i in 1:2000-4
                k = Tuple(@view(diff_prices[i:i+3]))
                p = prices[i+4]
                if !haskey(delta_to_prices_seq, k)
                    delta_to_prices_seq[k] = p
                end
            end
            for (k,v) in delta_to_prices_seq
                delta_to_prices[k] = get(delta_to_prices, k, 0) + v
            end
        end
        return findmax(delta_to_prices)[1]
    end

    function main()
        #@show part1("demo.txt")
        #@show part1("input.txt")
        @show part2("demo2.txt")
        @show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
