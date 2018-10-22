using JuMP

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

function KnapsackApproach(plan::DegreePlan, max_credit_hours::Int)
    # Min problem
    m = Model(solver=CbcSolver())

    @variable(m, x[1:8], Bin)

    capacty = max_credit_hours

    terms = Array{Int}(undef, 0)
    credit_hours = Array{Int}(undef, 0)

    for i = 1:plan.num_terms
        push!(terms, i)
        push!(credit_hours, plan.terms[i].credit_hours)
    end

    # Objective: minimize semester duration
    @objective(m, Min, dot(terms, x))

    # Constraint: credit hours in a semester have to be less than students max
    @constraint(m, dot(credit_hours, x) <= capacity)

    # Solve problem using MIP solver
    status = solve(m)

    println("Objective is: ", getobjectivevalue(m))
    println("Solution is:")
    for i = 1:8
        print("x[$i] = ", getvalue(x[i]))
        println(", p[$i]/w[$i] = ", terms[i]/credit_hours[i])
    end
end