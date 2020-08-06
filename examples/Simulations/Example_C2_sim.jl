using CurricularAnalytics

include("../Introduction/Example_C2.jl")

num_students = 10
duration = 4
max_credits = 6
course_passrate = 0.7

setPassrates(c, course_passrate)

students = simpleStudents(num_students)
simulation = simulate(dp, students, max_credits = max_credits, duration = duration)

simulationReport(simulation, duration, course_passrate, max_credits)
