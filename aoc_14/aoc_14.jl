#!/usr/bin/env -S julia --project
module AdventOfCodeDay14
    function parse_part1(filename::String)
        p = r"p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)"
        #positions = CartesianIndex{2}[]
        #velocities = CartesianIndex{2}[]
        positions = Tuple{Int, Int}[]
        velocities = Tuple{Int, Int}[]
        for line in eachline(filename)
            m = match(p, line)
            if isnothing(m)
                error("Cannot match the following line:\n$line")
            end
            position = parse.(Int, (m.captures[1], m.captures[2]))
            #position = CartesianIndex(position)
            velocity = parse.(Int, (m.captures[3], m.captures[4]))
            #velocity = CartesianIndex(velocity)
            push!(positions, position)
            push!(velocities, velocity)
        end
        return positions, velocities
    end

    function score(positions, velocities, time)
        sz = (101, 103)
        # sz = (11, 7)
        mid = div.(sz, 2, RoundDown)
        v100 = map(velocities) do v
            time .* v
        end
        final_positions = map(positions, v100) do p,v
            mod.(p .+ v, sz)
        end
        q1 = count(final_positions) do p
            b = p[1] < mid[1] && p[2] < mid[2]
            return b
        end
        q2 = count(final_positions) do p
            p[1] > mid[1] && p[2] < mid[2]
        end
        q3 = count(final_positions) do p
            p[1] > mid[1] && p[2] > mid[2]
        end
        q4 = count(final_positions) do p
            p[1] < mid[1] && p[2] > mid[2]
        end
        #@info "quadrants" q1 q2 q3 q4
        return q1*q2*q3*q4
    end

    function part1(filename::String, time=100)
        positions, velocities = parse_part1(filename)
        return score(positions, velocities, time)
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        positions, velocities = parse_part1(filename)
        min_score, time = findmin(1:(101*103)) do time
            score(positions, velocities, time)
        end

        # visualize
        sz = (101, 103)
        m = zeros(Int, sz)
        v_min = map(velocities) do v
            time .* v
        end
        positions = map(positions, v_min) do p,v
            mod.(p .+ v, sz)
        end
        for p in positions
            m[CartesianIndex(p .+ (1,1))] += 1
        end
        for col in eachcol(m)
            s = map(col) do p
                p > 0 ? '⬜' : '⬛'
            end
            println(String(s))
        end

        return time
    end

    function main()
        #@show part1("demo.txt")
        @show part1("input.txt")
        #@show part2("demo.txt")
        @show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
