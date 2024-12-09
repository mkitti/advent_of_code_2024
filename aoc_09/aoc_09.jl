#!/usr/bin/env -S julia --project
module AdventOfCodeDay09
    function parse_part1(filename::String)
        line = readline(filename)
        chars = Vector{Char}(line)
        nums = parse.(Int, chars)
        return nums
    end

    function part1(filename::String)
        input = parse_part1(filename)
        total_length = sum(input)
        disk = zeros(Int, total_length)
        file = true
        file_id = 0
        i = 1
        for num in input
            if file
                for _ in 1:num
                    disk[i] = file_id
                    i += 1
                end
                file_id += 1
            else
                for _ in 1:num
                    disk[i] = -1
                    i += 1
                 end
            end
            file = !file
        end
        free_count = count(==(-1), disk)
        file_space_count = count(!=(-1), disk)
        last_file = findlast(!=(-1), disk)
        while last_file > file_space_count
            first_free = findfirst(==(-1), disk)
            # swap
            disk[first_free], disk[last_file] =
                disk[last_file], disk[first_free]
            last_file = findlast(!=(-1), disk)
        end
        checksum = (0:last_file-1)' * @view(disk[1:last_file])
        @info "status" free_count disk
        return checksum
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        input = parse_part1(filename)
        total_length = sum(input)
        disk = zeros(Int, total_length)
        file = true
        file_id = 0
        i = 1
        file_sizes = Int[]
        file_locs = Int[]
        for num in input
            if file
                push!(file_sizes, num)
                push!(file_locs, i)
                for _ in 1:num
                    disk[i] = file_id
                    i += 1
                end
                file_id += 1
            else
                for _ in 1:num
                    disk[i] = -1
                    i += 1
                 end
            end
            file = !file
        end
        file_id -= 1
        max_file_id = file_id
        println(max_file_id)
        while file_id >= 0
            file_size = file_sizes[file_id+1]
            file_loc = file_locs[file_id+1]
            free_space_map = UInt8.(disk .== -1)
            free_space_loc = findfirst(repeat([0x1], file_size), free_space_map)
            if !isnothing(free_space_loc) && first(free_space_loc) < file_loc
                #@info "moving" free_space_loc file_id file_loc file_size
                disk[free_space_loc] .= file_id
                disk[file_loc:(file_loc+file_size-1)] .= -1
            end
            file_id -= 1
        end
        #@info "status" disk
        #println(disk)
        disk[disk .== -1] .= 0
        checksum = (0:length(disk)-1)' * disk
        return checksum
    end

    function main()
        #@show part1("demo.txt")
        #@show part1("input.txt")
        @show part2("demo.txt")
        @show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
