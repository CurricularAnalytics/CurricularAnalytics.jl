using CurricularAnalytics

include("../Introduction/Example_C1.jl")

duration = 4
max_credits = 6
course_passrate = 0.7

setPassrates(c, course_passrate)

students = simpleStudents(10)
sim = simulate(dp, students, max_credits = max_credits, duration = duration)

println()
println("------------ Simulation Report ------------")

println()
println("-------- Simulation Statistics --------")

str = "Number of terms: " * string(duration)
println(str)

str = "Number of Students: " * string(sim.numStudents)
println(str)

str = "Course Pass Rates(same for all courses): " * string(course_passrate * 100) * "%"
println(str)

println()
println("-------- Graduation Statistics --------")

str = "Number of Graduated Students: " * string(length(sim.graduatedStudents))
println(str)

str = "Graduate Rate: " * string(sim.gradRate * 100) * "%"
println(str)

println("Term Graduation Rates: ")
println(sim.termGradRates)

str = "Average number of semesters it takes to graduate students: " * string(sim.timeToDegree)
println(str)

println()
println("-------- Stopped out Statistics --------")

str = "Number of Stopped out Students: " * string(length(sim.stopoutStudents))
println(str)

str = "Stopped out Rate: " * string(sim.stopoutRate * 100) * "%"
println(str)

println("Term Stopped out Rates: ")
println(sim.termStopoutRates)

println()
println("-------------------------------------------")
