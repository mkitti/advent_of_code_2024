#!/usr/bin/env -S julia --project
module AdventOfCodeDay15
    function parse_part1(filename::String)
        puzzle_map = Vector{Char}[]
        parsing_puzzle = true
        instructions = Vector{Char}[]
        for line in eachline(filename)
            if isempty(line)
                parsing_puzzle = false
                continue
            end
            if parsing_puzzle
                push!(puzzle_map, Vector{Char}(line))
            else
                push!(instructions, Vector{Char}(line))
            end
        end
        # @show(puzzle_map)
        # @show(instructions)
        puzzle_map = stack(puzzle_map, dims=1)
        instructions = vcat(instructions...)
        return puzzle_map, instructions
    end

    const moves = Dict(
        '^' => CartesianIndex(-1, 0),
        '>' => CartesianIndex( 0, 1),
        'v' => CartesianIndex( 1, 0),
        '<' => CartesianIndex( 0,-1)
    )

    function attempt_move(obj::CartesianIndex, puzzle_map::Matrix{Char}, move::Char)
        return attempt_move(obj, puzzle_map, moves[move])
    end
    function attempt_move(obj::CartesianIndex, puzzle_map::Matrix{Char}, move::CartesianIndex)
        move_to = obj + move
        if puzzle_map[move_to] == '.'
            obj_char = puzzle_map[obj]
            puzzle_map[obj] = '.'
            puzzle_map[move_to] = obj_char
            return true
        elseif puzzle_map[move_to] == '#'
            return false
        elseif puzzle_map[move_to] == 'O'
            can_move = attempt_move(move_to, puzzle_map, move)
            if can_move
                obj_char = puzzle_map[obj]
                puzzle_map[obj] = '.'
                puzzle_map[move_to] = obj_char
            end
            return can_move
        end
    end

    function display_puzzle_map(puzzle_map::Matrix{Char})
        println("\033[2J\033[H")
        for row in eachrow(puzzle_map)
            println(String(row))
        end
        sleep(0.1)
    end

    function part1(filename::String)
        puzzle_map, instructions = parse_part1(filename)
        display_puzzle_map(puzzle_map)
        robot_location = findfirst(==('@'), puzzle_map)
        @show robot_location
        for move in instructions
            moved = attempt_move(robot_location, puzzle_map, move)
            if moved
                robot_location += moves[move]
            end
            # @info "Attempted move" move moved robot_location
            # display_puzzle_map(puzzle_map)
        end
        boxes = findall(==('O'), puzzle_map)
        map(boxes) do box
            (box[1]-1)*100 + (box[2] - 1)
        end |> sum
    end

    function parse_part2(filename::String)
        puzzle_map, instructions = parse_part1(filename)
        puzzle_map2 = Matrix{Char}(undef, size(puzzle_map) .* (1,2))
        left = @view puzzle_map2[:, 1:2:end]
        right = @view puzzle_map2[:, 2:2:end]
        for idx in CartesianIndices(puzzle_map)
            if puzzle_map[idx] == '#'
                left[idx] = '#'
                right[idx] = '#'
            elseif puzzle_map[idx] == 'O'
                left[idx] = '['
                right[idx] = ']'
            elseif puzzle_map[idx] == '@'
                left[idx] = '@'
                right[idx] = '.'
            elseif puzzle_map[idx] == '.'
                left[idx] = '.'
                right[idx] = '.'
            end
        end
        return puzzle_map2, instructions
    end

    function attempt_move2(obj::CartesianIndex, puzzle_map::Matrix{Char}, move::Char)
        return attempt_move2(obj, puzzle_map, moves[move])
    end
    function attempt_move2(obj::CartesianIndex, puzzle_map::Matrix{Char}, move::CartesianIndex)
        move_to = obj + move
        if puzzle_map[move_to] == '.'
            obj_char = puzzle_map[obj]
            puzzle_map[obj] = '.'
            puzzle_map[move_to] = obj_char
            @info "attempt_move2" obj move true
            display_puzzle_map(puzzle_map)
            return true
        elseif puzzle_map[move_to] == '#'
            @info "attempt_move2" obj move false
            return false
        elseif puzzle_map[move_to] == '[' || puzzle_map[move_to] == ']'
            other_side = if puzzle_map[move_to] == '['
                CartesianIndex(0,1)
            elseif puzzle_map[move_to] == ']'
                CartesianIndex(0,-1)
            end
            if move == CartesianIndex(1,0) || move == CartesianIndex(-1,0)
                can_move = attempt_box_move(move_to, puzzle_map, move)
            else
                # left right simple case
                can_move = attempt_move2(move_to, puzzle_map, move)
            end
            if can_move
                obj_char = puzzle_map[obj]
                puzzle_map[obj] = '.'
                puzzle_map[move_to] = obj_char
            end
            @info "attempt_move2" obj move can_move
            display_puzzle_map(puzzle_map)
            return can_move
        end
    end
    function attempt_box_move(obj::CartesianIndex, puzzle_map::Matrix{Char}, move::CartesianIndex)
        if puzzle_map[obj] == '['
            left = obj
            right = left + CartesianIndex(0, 1)
        else puzzle_map[obj] == ']'
            right = obj
            left = right + CartesianIndex(0, -1)
        end
        move_to_left = left + move
        move_to_right = right + move
        if puzzle_map[move_to_left] == '.' && puzzle_map[move_to_right] == '.'
            left_char = puzzle_map[left]
            right_char = puzzle_map[right]
            puzzle_map[left] = '.'
            puzzle_map[right] = '.'
            puzzle_map[move_to_left] = left_char
            puzzle_map[move_to_right] = right_char
            return true
        end
        if puzzle_map[move_to_left] == '#' || puzzle_map[move_to_right] == '#'
            return false
        end
        if puzzle_map[move_to_left] == '[' && puzzle_map[move_to_right] == ']'
            can_move = attempt_box_move(move_to_left, puzzle_map, move)
            if can_move
                left_char = puzzle_map[left]
                right_char = puzzle_map[right]
                puzzle_map[left] = '.'
                puzzle_map[right] = '.'
                puzzle_map[move_to_left] = left_char
                puzzle_map[move_to_right] = right_char
            end
            return can_move
        end
        can_move = true
        puzzle_map_copy = copy(puzzle_map)
        if puzzle_map[move_to_left] == ']'
            can_move &= attempt_box_move(move_to_left, puzzle_map_copy, move) 
        end
        if puzzle_map[move_to_right] == '['
            can_move &= attempt_box_move(move_to_right, puzzle_map_copy, move) 
        end
        if can_move
            puzzle_map .= puzzle_map_copy
            left_char = puzzle_map[left]
            right_char = puzzle_map[right]
            puzzle_map[left] = '.'
            puzzle_map[right] = '.'
            puzzle_map[move_to_left] = left_char
            puzzle_map[move_to_right] = right_char
        end
        return can_move
    end

    function part2(filename::String)
        puzzle_map, instructions = parse_part2(filename)
        display_puzzle_map(puzzle_map)
        robot_location = findfirst(==('@'), puzzle_map)
        @show robot_location
        for move in instructions
            moved = attempt_move2(robot_location, puzzle_map, move)
            if moved
                robot_location += moves[move]
            end
            @info "Attempted move" move moved robot_location
            display_puzzle_map(puzzle_map)
            #readline()
        end
        boxes = findall(==('['), puzzle_map)
        map(boxes) do box
            (box[1]-1)*100 + (box[2] - 1)
        end |> sum
    end

    function main()
        #@show part1("small_demo.txt")
        #@show part1("demo.txt")
        #@show part1("input.txt")
        @show part2("small_demo2.txt")
        @show part2("demo.txt")
        @show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
