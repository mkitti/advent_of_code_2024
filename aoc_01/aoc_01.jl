#!/usr/bin/env -S julia --project
function total_distance(filename::String)
    matrix = part1_parse(filename)
    A = sort(matrix[:,1])
    B = sort(matrix[:,2])
    abs.(A .- B) |> sum
end

function part1_parse(filename::String)
    stack(
        map(eachline(filename)) do line
            nums = split(line)
            map(nums) do num
                parse(Int, num)
            end
        end,
        dims=1
    )
end

function similarity(filename::String)
    matrix = part1_parse(filename)
    A = @view matrix[:,1]
    B = @view matrix[:,2]
    sum(map(A) do a
        a*count(==(a), B)
    end)
end

function part1()
    @show total_distance("demo.txt")
    @show total_distance("input.txt")
end

function part2()
    @show similarity("demo.txt")
    @show similarity("input.txt")
end

function main()
    part1()
    part2()
end

main()
