#println("Semester Count", getObjectiveValue(min), "semesters")
#println("In the following degree plan")
#println(get(dp), "Degree Plan")
#println("With maximum", getValue(maxcredithour), "cresit hours per semester")

using JuMP
using Cbc 

m = Model(solver=CbcSolver())


@variable(m, pennies >= 0)
@variable(m, nickels >= 0, Int)
@variable(m, dimes >= 0, Int)
@variable(m, quarters >= 0, Int)

# We need at least 99 cents
@constraint(m, 1 * pennies + 5 * nickels + 10 * dimes + 25 * quarters >= 99)

# Minimize mass (Grams)
# (source: US Mint)
@objective(m, Min, 2.5 * pennies + 5 * nickels + 2.268 * dimes + 5.670 * quarters)

# Solve
status = solve(m)

println("Minimum weight: ", getobjectivevalue(m), " grams")
println("using:")
println(round(getvalue(pennies)), " pennies") # "round" to cast as integer
println(round(getvalue(nickels)), " nickels")
println(round(getvalue(dimes)), " dimes")
println(round(getvalue(quarters)), " quarters")
