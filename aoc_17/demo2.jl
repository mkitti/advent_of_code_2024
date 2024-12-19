function program(A)
B = 0
C = 0
out = Int[]
operand_value = 3
A = A ÷ 2^operand_value
operand_value = A
push!(out, operand_value % 8)
operand_value = 0
operand_value = 3
A = A ÷ 2^operand_value
operand_value = A
push!(out, operand_value % 8)
operand_value = 0
operand_value = 3
A = A ÷ 2^operand_value
operand_value = A
push!(out, operand_value % 8)
operand_value = 0
operand_value = 3
A = A ÷ 2^operand_value
operand_value = A
push!(out, operand_value % 8)
operand_value = 0
operand_value = 3
A = A ÷ 2^operand_value
operand_value = A
push!(out, operand_value % 8)
operand_value = 0
operand_value = 3
A = A ÷ 2^operand_value
operand_value = A
push!(out, operand_value % 8)
operand_value = 0
return out == [0, 3, 5, 4, 3, 0]
end
