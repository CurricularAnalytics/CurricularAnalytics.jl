using JuMP
using Cbc

function LinearApproach()
    lpModel = Model(solver = CbcSolver(seconds = 3600))

    @variable(lpModel, x >= 8)
    @variable(lpModel, y >= 16)

    @constraint(lpModel, x+y == 120)

    @objective(lpModel, Max, x + y)

    status = JuMP.solve(lpModel)

    diff = c1.metrics[k][1] - c2.metrics[k][1]

    println("Number of Semesters: $(getvalue(x))")
    println("Number of Credit Hours : $(getvalue(y))")
end

function KnapsackApproach()
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
end