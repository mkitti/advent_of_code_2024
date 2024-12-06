#!/usr/bin/env -S julia --project
module AdventOfCodeDay05
    function parse_part1(filename::String)
        parsing_rules = true
        rules = Dict{Int, Vector{Int}}()
        updates = Vector{Int}[]
        for line in eachline(filename)
            if isempty(line)
                parsing_rules = false
                continue
            end
            if parsing_rules
                x, y = parse.((Int,), split(line, "|"))
                v = get(rules, x, Int[])
                push!(v, y)
                rules[x] = v
            else
                push!(updates, parse.((Int,), split(line, ",")))
            end
        end
        return rules, updates
    end

    function check_update(update, rules)
        for (i, page) in pairs(update)
            prev_pages = update[1:i-1]
            after_pages = get(rules, page, Int[])
            if any(in(after_pages), prev_pages)
                return false
            end
        end
        return true
    end

    function part1(filename::String)
        s = 0
        rules, updates = parse_part1(filename)
        for update in updates
            if check_update(update, rules)
                #@info "Good update" update
                s += update[(end+1)÷2]
            else
                #@info "Bad update" update
            end
        end
        return s
    end

    #=
    function fix_update(update, rules)
        reversed_new_update = Int[]
        for (i, page) in reverse(pairs(update))
            prev_pages = update[1:i-1]
            after_pages = get(rules, page, Int[])
            if any(in(after_pages), prev_pages)
                pages_to_move 
                for prev_page in prev_pages
                    if prev_page in after_pages
                    end
                end
            else
                push!(reversed_new_update, page)
            end
        end
        new_update = reverse(reversed_new_update)
        return new_update
    end
    =#
    struct Page
        page::Int
    end
    function make_page_isless(rules)
        function isless(x::Page, y::Page)
            after_x_pages = get(rules, x.page, Int[])
            if y.page ∈ after_x_pages
                return true
            end
            return false
        end
        return isless
    end
    Int(p::Page) = p.page

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        s = 0
        rules, updates = parse_part1(filename)
        isless = make_page_isless(rules)
        for update in updates
            if check_update(update, rules)
            else
                # fixed_update = fix_update(update, rules)
                #
                fixed_update = sort(Page.(update), lt=isless)
                fixed_update = Int.(fixed_update)
                @debug "Fixed" update fixed_update
                s += fixed_update[(end+1)÷2]
            end
        end
        return s
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
