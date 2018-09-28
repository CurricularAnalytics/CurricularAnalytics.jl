using JuMP
using Cbc

# Min problem
m = Model(solver=CbcSolver())

@variable(m, x[1:8], Bin)

semester = [ 1, 2, 3, 4, 5, 6, 7, 8 ]
credit_hours = [ 12, 16, 16, 14, 12, 15 ,15, 18  ]
capacity = 16

# Objective: minimize semester duration
@objective(m, Min, dot(semester, x))

# Constraint: credit hours in a semester have to be less than students max
@constraint(m, dot(credit_hours, x) <= capacity)

# Solve problem using MIP solver
status = solve(m)

println("Objective is: ", getobjectivevalue(m))
println("Solution is:")
for i = 1:8
    print("x[$i] = ", getvalue(x[i]))
    println(", p[$i]/w[$i] = ", semester[i]/credit_hours[i])
end
