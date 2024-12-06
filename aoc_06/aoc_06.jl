#!/usr/bin/env -S julia --project
module AdventOfCodeDay06
    const moves = CartesianIndex.([
        (-1, 0),
        ( 0, 1),
        ( 1, 0),
        ( 0,-1)
    ])

    function move(guard_pos, guard_dir, obstacles)
        new_pos = guard_pos + moves[guard_dir]
        checkbounds(Bool, obstacles, new_pos) || return new_pos, guard_dir
        while obstacles[new_pos]
            guard_dir = mod1(guard_dir+1, length(moves))
            new_pos = guard_pos + moves[guard_dir]
            if !checkbounds(Bool, obstacles, new_pos)
                break
            end
        end
        return new_pos, guard_dir
    end

    function parse_part1(filename::String)
        lines = map(eachline(filename)) do line
            Vector{Char}(line)
        end
        return stack(lines, dims=1)
    end

    function render(tracker, obstacles)
        chars = map(tracker) do p
            if p
                '■'
            else
                '□'
            end
        end
        for row in eachrow(chars)
            println(String(row))
        end
    end

    function track_moves(guard_pos, guard_dir, obstacles)
        tracker = zeros(Bool, size(obstacles))
        f = open("track.txt", "w")
        while checkbounds(Bool, obstacles, guard_pos)
            tracker[guard_pos] = true
            guard_pos, guard_dir = move(guard_pos, guard_dir, obstacles)
            println(f, "$guard_pos, $guard_dir")
        end
        close(f)
        return tracker
    end

    function part1(filename::String)
        input = parse_part1(filename)
        obstacles = input .== '#'
        guard = input .== '^'
        guard_pos = findfirst(guard)
        guard_dir = 1
        tracker = track_moves(guard_pos, guard_dir, obstacles)
        return sum(tracker)
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function check_loop(guard_pos, guard_dir, obstacles, new_obstacle)
        tracker = Dict{Tuple{CartesianIndex{2}, Int}, Bool}()
        old_state = obstacles[new_obstacle]
        obstacles[new_obstacle] = true
        while checkbounds(Bool, obstacles, guard_pos)
            if haskey(tracker,(guard_pos,guard_dir))
                obstacles[new_obstacle] = old_state
                return true
            end
            tracker[(guard_pos,guard_dir)] = true
            guard_pos, guard_dir = move(guard_pos, guard_dir, obstacles)
        end
        obstacles[new_obstacle] = old_state
        return false
    end

    function part2(filename::String)
        input = parse_part1(filename)
        obstacles = input .== '#'
        guard = input .== '^'
        guard_pos = findfirst(guard)
        guard_dir = 1
        visited = track_moves(guard_pos, guard_dir, obstacles)
        n = 0
        for new_obstacle in findall(visited)
            if new_obstacle != guard_pos
                isloop = check_loop(guard_pos, guard_dir, obstacles, new_obstacle)
                if isloop
                    n += 1
                end
            end
        end
        return n
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
