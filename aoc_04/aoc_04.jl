#!/usr/bin/env -S julia --project
using ImageFiltering

function get_patterns(base_patterns)
    patterns = base_patterns
    patterns = vcat(patterns, reverse.(patterns))
    patterns = vcat(patterns, rotl90.(patterns), rot180.(patterns), rotr90.(patterns))
    patterns = unique(patterns)
    return patterns
end

function find_xmas(filename::String, patterns::Vector{Matrix{Char}})
    target = sum(Int.(patterns[1]).^2)
    puzzle = Vector{Char}.(readlines(filename)) |> x->stack(x,dims=1)
    map(patterns) do p
           imfilter(Int.(puzzle), centered(Int.(p)), Fill(0)) .== target
    end .|> sum |> sum
end


function part1()
    base_patterns = Matrix{Char}[
        ['X' 'M' 'A' 'S'],
        ['X'  0   0   0
          0  'M'  0   0
          0   0  'A'  0
          0   0   0  'S']
    ]

    patterns = get_patterns(base_patterns)

    @show find_xmas("demo.txt", patterns)
    @show find_xmas("input.txt", patterns)
end

function part2()
    base_patterns_2 = Matrix{Char}[
        ['M' 0 'S'
          0 'A' 0
         'M' 0 'S']
    ]
    patterns2 = get_patterns(base_patterns_2)

    @show find_xmas("demo.txt", patterns2)
    @show find_xmas("input.txt", patterns2)
end

function main()
    part1()
    part2()
end

main()
