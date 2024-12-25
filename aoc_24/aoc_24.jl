#!/usr/bin/env -S julia --project
module AdventOfCodeDay24
    using Printf
    function parse_part1(filename::String)
        init = true
        bindings = Dict{String, Bool}()
        gates = Dict{String, Tuple{Symbol, String, String}}()
        for line in eachline(filename)
            if isempty(line)
                init = false
                continue
            end
            if init
                binding, val = split(line, ": ")
                bindings[binding] = parse(Int, val)
                continue
            end
            arg1, op, arg2, _, res = split(line, ' ')
            gates[res] = (Symbol(op), arg1, arg2)
        end
        return bindings, gates
    end

    const OPS = (; XOR = xor, OR = |, AND = &)

    function part1(filename::String)
        bindings, gates = parse_part1(filename)
        compute!(bindings, gates)
        evaluate('z', bindings)
    end

    function compute!(bindings, gates)
        # n_gates = length(gates)
        # gates_waiting = n_gates
        while !isempty(gates)
            completed = String[]
            for (k,v) in gates
                if haskey(bindings, v[2]) && haskey(bindings, v[3])
                    op = OPS[v[1]]
                    arg1 = bindings[v[2]]
                    arg2 = bindings[v[3]]
                    bindings[k] = op(arg1, arg2)
                    push!(completed, k)
                end
            end
            for k in completed
                delete!(gates, k)
            end
        end
        z = 0
        for (k,v) in bindings
            if startswith(k, "z")
                i = parse(Int, @view k[2:3])
                z |= (bindings[k] << i)
            end
        end
        return z
    end

    function evaluate(c::Char, bindings)
        z = 0
        for (k,v) in bindings
            if startswith(k, c)
                i = parse(Int, @view k[2:3])
                z |= (bindings[k] << i)
            end
        end
        return z
    end

    function parse_part2(filename::String)
        parse_part1(filename)
    end

    function find_xy_ancestors(arg, gates)
        if startswith(arg, 'x') || startswith(arg, 'y')
            return [arg]
        end
        _, arg1, arg2 = gates[arg]
        ancestor1 = find_xy_ancestors(arg1, gates)
        ancestor2 = find_xy_ancestors(arg2, gates)
        # @info "find_xy" arg arg1 arg2 ancestor1 ancestor2
        return append!(ancestor1, ancestor2)
        #=
        if startswith(ancestor1[1], 'x')
            return ancestor1[1], ancestor2[1]
        else
            return ancestor2[1], ancestor1[1]
        end
        =#
    end

    function set_binding!(bindings, char::Char, value)
        for k in keys(bindings)
            if startswith(k, char)
                i = parse(Int, @view(k[2:3]))
                bindings[k] = (value >> i) & 1
                # @info "set_binding!" char value i k bindings[k]
            end
        end
    end

    function set_x!(bindings, x)
        set_binding!(bindings, 'x', x)
    end

    function set_y!(bindings, y)
        set_binding!(bindings, 'y', y)
    end

    struct ReverseGateDict
        d::Dict{Tuple{Symbol, String, String}, String}
    end
    function Base.getindex(rgd::ReverseGateDict, key::Tuple{Symbol, String, String})
        if haskey(rgd.d, key)
            return rgd.d[key]
        end
        rkey = (key[1], key[3], key[2])
        if haskey(rgd.d, rkey)
            return rgd.d[rkey]
        end
        error("ReverseGateDict cannot find $key or $rkey in parent")
    end
    Base.parent(rgd::ReverseGateDict) = rgd.d

    function part2(filename::String)
        bindings, gates = parse_part1(filename)
        # compute!(bindings, gates)
        # return evaluate('z', bindings)
        z_gates = sort(collect(filter(startswith('z'), keys(gates))))
        x_bindings = sort(collect(filter(startswith('x'), keys(bindings))))
        y_bindings = sort(collect(filter(startswith('y'), keys(bindings))))
        n_x = parse(Int, x_bindings[end][2:3]) + 1
        n_y = parse(Int, y_bindings[end][2:3]) + 1
        set_x!(bindings, 0)
        set_y!(bindings, 0)
        for i in -1:n_x-1
            local_bindings = copy(bindings)
            local_gates = copy(gates)
            #set_x!(local_bindings, 1 << i)
            set_y!(local_bindings, 1 << i)
            compute!(local_bindings, local_gates)
            x = evaluate('x', local_bindings)
            y = evaluate('y', local_bindings)
            z = evaluate('z', local_bindings)
            if z != x + y
                @show i x y z x+y
            end
        end

        reverse_gates = Dict{Tuple{Symbol, String, String}, String}()
        for (k,v) in gates
            reverse_gates[v] = k
        end
        reverse_gates = ReverseGateDict(reverse_gates)
        cn = ""
        for i in 0:n_x-1
            N = @sprintf("%02d", i)
            xor_a_key = (:XOR, "x$N", "y$N")
            and_a_key = (:AND, "x$N", "y$N")
            xor_a = reverse_gates[xor_a_key]
            and_a = reverse_gates[and_a_key]
            if !isempty(cn)
                xor_b_key = (:XOR, xor_a, cn)
                and_b_key = (:AND, xor_a, cn)
                if gates["z$N"] != xor_b_key && gates["z$N"] != xor_b_key[[1,3,2]]
                    @error "Mismatch z$N and xor_b_key" xor_a and_a xor_b_key gates["z$N"] cn
                    zn_gate = gates["z$N"]
                    # swap cn
                    if zn_gate[2] == xor_a && zn_gate[1] == :XOR
                        @warn "Swap" cn zn_gate[3]
                        cn = zn_gate[3]
                    elseif zn_gate[3] == xor_a && zn_gate[1] == :XOR
                        # TODO: Deal with case when cn == zn_gate[2]
                        @warn "Swap" cn zn_gate[2]
                        cn = zn_gate[2]
                    elseif zn_gate[2] == cn && zn_gate[1] == :XOR
                        @warn "Swap" xor_a zn_gate[3]
                        and_a = xor_a
                        xor_a = zn_gate[3]
                    elseif zn_gate[3] == cn && zn_gate[1] == :XOR
                        @warn "Swap" xor_a zn_gate[2]
                        and_a = xor_a
                        xor_a = zn_gate[2]
                    else
                        #zn xor_b_key mismatch when zn has neither xor_a or cn
                        # @warn "Need to swap?" reverse_gates[xor_b_key] "z$N" cn and_a
                        if and_a == "z$N"
                            @warn "Swap" and_a reverse_gates[xor_b_key]
                            and_a = reverse_gates[xor_b_key]
                        else
                            if gates["z$N"] == and_b_key
                                @warn "Swap" reverse_gates.d[and_b_key] reverse_gates[xor_b_key]
                                reverse_gates.d[and_b_key] = reverse_gates[xor_b_key]
                            elseif gates["z$N"] == and_b_key[[1,3,2]]
                                @warn "Swap" reverse_gates.d[and_b_key[[1,3,2]]] reverse_gates[xor_b_key]
                                reverse_gates.d[and_b_key[[1,3,2]]] = reverse_gates[xor_b_key]
                            end
                            # and_b = reverse_gates[xor_b_key]
                            # cn = reverse_gates[xor_b_key]
                            #error("Cannot resolve mismatch between z$N and xor_b_key")
                        end
                    end
                    xor_b_key = (:XOR, xor_a, cn)
                    and_b_key = (:AND, xor_a, cn)
                end
                try
                    xor_b = reverse_gates[xor_b_key]
                    zn = xor_b
                catch err
                    @error "Cannot locate xor_b for $i" xor_b_key gates["z$N"]
                    return
                end
                try
                    and_b = reverse_gates[and_b_key]
                    or_key = (:OR, and_a, and_b)
                    or = reverse_gates[or_key]
                    # xor_b == "z$N"
                    cn = or
                catch err
                    @error "Cannot locate and_b or `or`" and_b_key and_a xor_b_key
                    rethrow(err)
                end
            else
                zn = xor_a
                cn = and_a
            end
        end

        #=
        for z_gate in z_gates
            ancestors = find_xy_ancestors(z_gate, gates)
            x_ancestors = sort(filter(startswith('x'), ancestors))
            y_ancestors = sort(filter(startswith('y'), ancestors))
            @info z_gate x_ancestors[end] y_ancestors[end]
        end
        =#
        # compute!(bindings, gates)
        # @show x = evaluate('x', bindings)
        # @show y = evaluate('y', bindings)
        # @show z = evaluate('z', bindings)
        # @show bitstring(x)
        # @show bitstring(y)
        # @show bitstring(z)
    end

    function main()
        #@show part1("demo.txt")
        #@show part1("input.txt")
        #@show part2("demo2.txt")
        @show part2("input.txt")
    end

    function __init__()
        if abspath(PROGRAM_FILE) == @__FILE__
            main()
        end
    end
end
