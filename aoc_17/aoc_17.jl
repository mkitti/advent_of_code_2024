#!/usr/bin/env -S julia --project
module AdventOfCodeDay17
    function parse_part1(filename::String)
        registers = Dict{Char,Int}()
        instructions = Int[]
        for line in eachline(filename)
            m = match(r"^Register (.*): (\d+)", line)
            if !isnothing(m)
                @assert(length(m.captures[1]) == 1)
                registers[m.captures[1][1]] = parse(Int, m.captures[2]) 
                continue
            end
            if isempty(line)
                continue
            end
            m = match(r"^Program: (.*)", line)
            if !isnothing(m)
                instructions = parse.(Int, split(m.captures[1], ","))
                continue
            end
            error("Could not parse line: $line")
        end
        return registers, instructions
    end

    function part1(filename::String)
        registers, instructions = parse_part1(filename)
        return part1(registers, instructions)
    end
    function part1(registers::Dict{Char, Int}, instructions::Vector{Int})
        output = Int[]

        # instruction pointer
        iptr = 0 
        while iptr < length(instructions)
            opcode = instructions[iptr+1]
            operand = instructions[iptr+2]
            operand_value = 0
            if operand < 4
                operand_value = operand
            elseif operand < 7
                operand_value = registers['A' + operand - 4]
            else
                operand_value = -1
                #error("Invalid combo operand: $operand")
            end
            if opcode == 0
                num = registers['A']
                den = 2^operand_value
                registers['A'] = num ÷ den
            elseif opcode == 1
                registers['B'] = xor(registers['B'], operand)
            elseif opcode == 2
                registers['B'] = operand_value % 8
            elseif opcode == 3
                if registers['A'] != 0
                    iptr = operand
                    continue
                end
            elseif opcode == 4
                registers['B'] = xor(registers['B'], registers['C'])
            elseif opcode == 5
                push!(output, operand_value % 8)
            elseif opcode == 6
                num = registers['A']
                den = 2^operand_value
                registers['B'] = num ÷ den
            elseif opcode == 7
                num = registers['A']
                den = 2^operand_value
                registers['C'] = num ÷ den
            else
                error("Invalid opcode: $opcode")
            end
            iptr += 2
        end
        return join(string.(output), ",")
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function part2(filename::String)
        registers, instructions = parse_part1(filename)
        io = IOBuffer()
        part2_decompile(io, registers, instructions)
        str = String(take!(io))
        println(str)
        eval(Meta.parse(str))
        f(args...) = invokelatest(program, args...)
        nums = Int[0]
        for byte in 1:length(instructions)
            tail = @view instructions[end-byte+1:end]
            new_nums = Int[]
            for num in nums
                search = num .+ (0:7)
                outputs = f.(search)
                idx = findall(==(tail), outputs)
                if isnothing(idx)
                    error("Could not find tail, $tail, with search, $search")
                end
                for i in idx
                    push!(new_nums, search[i] << 3)
                end
            end
            nums = new_nums
            @debug "searching..." nums tail
        end
        return minimum(nums) >> 3
    end

    function program2(A)
        # from part2_decompile
        operand_value = A
        B = operand_value % 8
        operand_value = 1
        B = xor(B,1)
        operand_value = B
        C = A ÷ 2^operand_value
        operand_value = B
        B = xor(B,5)
        operand_value = 1
        B = xor(B, C)
        operand_value = B
        if A >> 3 != 0
            return append!([operand_value%8], program2(A >> 3))
        else
            return [operand_value%8]
        end
    end

    function program3(A)
        # streamlined
        B = A % 8
        B = xor(B,1)
        C = A >> B
        B = xor(B,5)
        B = xor(B,C)
        if A >> 3 != 0
            return append!([B%8], program2(A >> 3))
        else
            return [B%8]
        end
    end


    function part1_decompile(filename::String)
        registers, instructions = parse_part1(filename)
        return part1_decompile(registers, instructions)
    end
    function part1_decompile(registers::Dict{Char, Int}, instructions::Vector{Int})
        output = Int[]

        println("function program(A)")

        #println("A = $(registers['A'])")
        println("B = $(registers['B'])")
        println("C = $(registers['C'])")

        println("out = Int[]")

        # instruction pointer
        iptr = 0 
        while iptr < length(instructions)
            opcode = instructions[iptr+1]
            operand = instructions[iptr+2]
            operand_value = 0
            if operand < 4
                operand_value = operand
                println("operand_value = $operand")
            elseif operand < 7
                operand_value = registers['A' + operand - 4]
                println("operand_value = $('A' + operand - 4)")
            else
                operand_value = -1
                #error("Invalid combo operand: $operand")
            end
            if opcode == 0
                num = registers['A']
                den = 2^operand_value
                registers['A'] = num ÷ den
                println("A = A ÷ 2^operand_value")
            elseif opcode == 1
                registers['B'] = xor(registers['B'], operand)
                println("B = xor(B,$operand)")
            elseif opcode == 2
                registers['B'] = operand_value % 8
                println("B = operand_value % 8")
            elseif opcode == 3
                println("""
                        if A != 0
                            iptr = operand
                        end
                        """
                       )
                if registers['A'] != 0
                    iptr = operand
                    continue
                end
            elseif opcode == 4
                registers['B'] = xor(registers['B'], registers['C'])
                println("B = xor(B, C)")
            elseif opcode == 5
                push!(output, operand_value % 8)
                println("push!(out, operand_value % 8)")
            elseif opcode == 6
                num = registers['A']
                den = 2^operand_value
                registers['B'] = num ÷ den
                println("B = A ÷ 2^operand_value")
            elseif opcode == 7
                num = registers['A']
                den = 2^operand_value
                registers['C'] = num ÷ den
                println("C = A ÷ 2^operand_value")
            else
                error("Invalid opcode: $opcode")
            end
            iptr += 2
        end

        println("return out == $instructions")

        println("end")

        return join(string.(output), ",")
    end

    function part2_decompile(filename::String)
        registers, instructions = parse_part1(filename)
        return part2_decompile(registers, instructions)
    end
    function part2_decompile(io::IO, registers::Dict{Char, Int}, instructions::Vector{Int})
        output = Int[]

        #println("instructions = $(instructions)")

        println(io, "function program(A)")

        #println("A = $(registers['A'])")
        println(io, "\tB = $(registers['B'])")
        println(io, "\tC = $(registers['C'])")

        # println("out = Int[]")

        # instruction pointer
        iptr = 0 
        while iptr < length(instructions)
            opcode = instructions[iptr+1]
            operand = instructions[iptr+2]
            operand_value = 0
            if operand < 4
                operand_value = operand
                println(io, "\toperand_value = $operand")
            elseif operand < 7
                operand_value = registers['A' + operand - 4]
                println(io, "\toperand_value = $('A' + operand - 4)")
            else
                operand_value = -1
                #error("Invalid combo operand: $operand")
            end
            if opcode == 0
                num = registers['A']
                den = 2^operand_value
                registers['A'] = num ÷ den
                println(io, "\tA = A >> operand_value")
            elseif opcode == 1
                registers['B'] = xor(registers['B'], operand)
                println(io, "\tB = xor(B,$operand)")
            elseif opcode == 2
                registers['B'] = operand_value % 8
                println(io, "\tB = operand_value % 8")
            elseif opcode == 3
                if operand == 0
                    # tail recursion
                    println(io, """
                    \tif A != 0
                    \t\treturn append!(output, program(A))
                    \telse
                    \t\treturn output
                    \tend
                    """)
                else
                    println(io, "\t# iptr = operand")
                    if registers['A'] != 0
                        iptr = operand
                        continue
                    end
                end
            elseif opcode == 4
                registers['B'] = xor(registers['B'], registers['C'])
                println(io, "\tB = xor(B, C)")
            elseif opcode == 5
                println(io, "\toutput = [operand_value%8]")
            elseif opcode == 6
                num = registers['A']
                den = 2^operand_value
                registers['B'] = num ÷ den
                println(io, "\tB = A >> operand_value")
            elseif opcode == 7
                num = registers['A']
                den = 2^operand_value
                registers['C'] = num ÷ den
                println(io, "\tC = A >> operand_value")
            else
                error("Invalid opcode: $opcode")
            end
            iptr += 2
        end

        # println("return out == $instructions")

        println(io, "end")

        return join(string.(output), ",")
    end



    function main()
        #@show part1("demo.txt")
        @show part1("input.txt")
        @show part1("input2.txt")
        @show part2("demo2.txt")
        @show part2("input.txt")
        #@show part2_decompile("demo2.txt")
        #@show part2_decompile("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
