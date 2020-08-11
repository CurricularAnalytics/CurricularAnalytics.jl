#using Pkg
#Pkg.activate("../..")
#Pkg.resolve()
#Pkg.instantiate()
using CurricularAnalytics

include("CurriculumPool.jl")

################### Change the Setting ###################
# config
num_students = 50
course_passrate = 0.8

max_credits = 19
duration = 14
durationLock = false
stopouts = true

performance_model = PassRate
enrollment_model = Enrollment

# Comment and uncomment to change the degree plan
# courses, degreePlan = Example_C1()      # refer to the curriculum in examples/Introduction/Example_C1.jl
# courses, degreePlan = Example_C2()      # refer to the curriculum in examples/Introduction/Example_C2.jl
# courses, degreePlan = UKY_EE_curric()   # refer to the curriculum in examples/UKY_EE_curric.jl

# Comment this whole section if use the courses and degree plan above
degreePlan = read_csv("./examples/Univ_of_Arizona-Aero.csv")     # change the degree plan csv file for different plan
courses = degreePlan.curriculum.courses
name = degreePlan.curriculum.name
println("\n $(degreePlan.curriculum.name), $(degreePlan.name)")

##########################################################

students = simpleStudents(num_students)    # Create a cohort of students for simulation
setPassrates(courses, course_passrate)     # set pass rate for all courses

# run simulation
simulation = simulate(degreePlan,
                      students,
                      max_credits = max_credits,
                      performance_model=PassRate,
                      enrollment_model=Enrollment,
                      duration = duration,
                      durationLock = durationLock,
                      stopouts = stopouts)

# print
simulationReport(simulation, duration, course_passrate, max_credits)
