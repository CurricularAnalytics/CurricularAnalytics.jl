using CurricularAnalytics

include("../UKY_EE_curric.jl")

num_students = 10
duration = 11
max_credits = 19
course_passrate = 0.7

setPassrates(c, course_passrate)

students = simpleStudents(num_students)
simulation = simulate(dp, students, max_credits = max_credits, duration = duration)

simulationReport(simulation, duration, course_passrate, max_credits)

println(c[2])
println(c[7])
