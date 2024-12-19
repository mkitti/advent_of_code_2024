instructions = [2, 4, 1, 1, 7, 5, 1, 5, 4, 1, 5, 5, 0, 3, 3, 0]
B = 0
C = 0
funcs = Function[]
function f1(A)
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
	return operand_value%8
end
push!(funcs, f1)
function f2(A)
	operand_value = 3
	#A = A ÷ 2^operand_value
	operand_value = 0
	if A != 0
    		#iptr = 0
    		return f1(A)
	end

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
	return operand_value%8
end
push!(funcs, f2)
function f3(A)
	operand_value = 3
	#A = A ÷ 2^operand_value
	operand_value = 0
	if A != 0
    		#iptr = 0
    		return f1(A)
	end

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
	return operand_value%8
end
push!(funcs, f3)
function f4(A)
	operand_value = 3
	#A = A ÷ 2^operand_value
	operand_value = 0
	if A != 0
    		#iptr = 0
    		return f1(A)
	end

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
	return operand_value%8
end
push!(funcs, f4)
function f5(A)
	operand_value = 3
	#A = A ÷ 2^operand_value
	operand_value = 0
	if A != 0
    		#iptr = 0
    		return f1(A)
	end

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
	return operand_value%8
end
push!(funcs, f5)
function f6(A)
	operand_value = 3
	#A = A ÷ 2^operand_value
	operand_value = 0
	if A != 0
    		#iptr = 0
    		return f1(A)
	end

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
	return operand_value%8
end
push!(funcs, f6)
function f7(A)
	operand_value = 3
	#A = A ÷ 2^operand_value
	operand_value = 0
	if A != 0
    		#iptr = 0
    		return f1(A)
	end

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
	return operand_value%8
end
push!(funcs, f7)
function f8(A)
	operand_value = 3
	#A = A ÷ 2^operand_value
	operand_value = 0
	if A != 0
    		#iptr = 0
    		return f1(A)
	end

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
	return operand_value%8
end
push!(funcs, f8)
function f9(A)
	operand_value = 3
	#A = A ÷ 2^operand_value
	operand_value = 0
	if A != 0
    		#iptr = 0
    		return f1(A)
	end

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
	return operand_value%8
end
push!(funcs, f9)
function f10(A)
	operand_value = 3
	#A = A ÷ 2^operand_value
	operand_value = 0
	if A != 0
    		#iptr = 0
    		return f1(A)
	end

	return operand_value%8
end
push!(funcs, f10)
