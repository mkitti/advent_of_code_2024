#!/usr/bin/env -S julia --project
module AdventOfCodeDay07
    function parse_part1(filename::String)
        equations = Vector{Int}[]
        for line in eachline(filename)
            parts = split(line)
            if parts[1][end] != ':'
                error("Invalid format. Colon missing.\n$line")
            end
            parts[1] = parts[1][1:end-1]
            numbers = parse.((Int,), parts)
            push!(equations, numbers)
        end
        return equations
    end

    function check_equation(test_value, equation)
        if length(equation) == 1
            @debug test_value == equation[1] test_value equation
            return test_value == equation[1]
        end
        if check_equation(test_value - equation[end], @view equation[1:end-1])
            @debug "Good via +" test_value equation
            return true
        end
        if rem(test_value, equation[end]) == 0
            if check_equation(test_value ÷ equation[end], @view equation[1:end-1])
                @debug "Good via *" test_value equation
                return true
            end
        end
        return false
    end

    function part1(filename::String)
        equations = parse_part1(filename)
        s = 0
        i = 0
        for equation in equations
            i += 1
            if check_equation(equation[1], @view equation[2:end])
                s += equation[1]
            end
        end
        return s
    end

    function parse_part2(filename::String)
        parse_part1()
    end

    function check_equation2(test_value, equation)
        if length(equation) == 1
            @debug test_value == equation[1] test_value equation
            return test_value == equation[1]
        end
        if check_equation2(test_value - equation[end], @view equation[1:end-1])
            @debug "Good via +" test_value equation
            return true
        end
        if rem(test_value, equation[end]) == 0
            if check_equation2(test_value ÷ equation[end], @view equation[1:end-1])
                @debug "Good via *" test_value equation
                return true
            end
        end
        n_digits = ceil(Int, log10(equation[end]))
        tenpow = 10^n_digits
        if test_value > 0 && mod(test_value, tenpow) == equation[end]
            @info "split" test_value test_value ÷ tenpow equation[end]
            if (test_value ÷ tenpow) * tenpow + equation[end] != test_value
                error("split is wrong: $equation")
            end
            if check_equation2(test_value ÷ tenpow, @view equation[1:end-1])
                return true
            end
        end
        return false
    end

    function check_equation3(test_value, running_value, equation)
        if length(equation) == 0
            return test_value == running_value
        end
        if check_equation3(test_value, running_value + equation[1], @view equation[2:end])
            return true
        end
        if check_equation3(test_value, running_value * equation[1], @view equation[2:end])
            return true
        end
        n_digits = floor(Int, log10(equation[1])) + 1
        tenpow = 10^n_digits
        if check_equation3(test_value, running_value*tenpow + equation[1], @view equation[2:end])
            return true
        end
        # alternative concatenation implementation
        #=
        new_value = parse(Int, string(running_value) * string(equation[1]))
        if check_equation3(test_value, new_value, @view equation[2:end])
            return true
        end
        =#
        return false
    end


    function part2(filename::String)
        equations = parse_part1(filename)
        s = BigInt(0)
        i = 0
        f = open("goodbad.txt", "w")
        for equation in equations
            i += 1
            # if check_equation2(equation[1], @view equation[2:end])
            if check_equation3(equation[1], equation[2], @view equation[3:end])
                # @info "Good" equation
                s += equation[1]
                println(f, "good: $(equation[1])")
            else
                println(f, "bad: $(equation[1])")
            end
            # @info "Bad" equation
        end
        close(f)
        return s
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
