using JuMP
using Cbc

lpModel = Model(solver = CbcSolver(seconds = 3600))

@variable(lpModel, x >= 8)
@variable(lpModel, y >= 16)

@constraint(lpModel, x+y == 120)

@objective(lpModel, Max, x + y)

status = JuMP.solve(lpModel)

diff = c1.metrics[k][1] - c2.metrics[k][1]

println("Number of Semesters: $(getvalue(x))")
println("Number of Credit Hours : $(getvalue(y))")
