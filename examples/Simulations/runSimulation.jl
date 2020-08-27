using Pkg
Pkg.activate("../..")
Pkg.resolve()
Pkg.instantiate()
using CurricularAnalytics

include("CurriculumPool.jl")

real_passrate = false # Don't modify this here

################### Configuration ###################

########## Basic configuration ##########
num_students = 10000
course_passrate = 0.9

max_credits = 19
duration = 12
duration_lock = false
stopouts = true
course_attempt_limit = 2

performance_model = PassRate
enrollment_model = Enrollment

########## Define a degree plan ##########
# Comment and uncomment to change the degree plan
# courses, degree_plan = Example_C1()      # refer to the curriculum in examples/Introduction/Example_C1.jl
# courses, degree_plan = Example_C2()      # refer to the curriculum in examples/Introduction/Example_C2.jl
# courses, degree_plan = UKY_EE_curric()   # refer to the curriculum in examples/UKY_EE_curric.jl

# Comment this whole section if use the courses and degree plan above
degree_plan = read_csv("Univ_of_Arizona-Aero.csv")     # change the degree plan csv file for different plan
courses = degree_plan.curriculum.courses
println("\n $(degree_plan.curriculum.name), $(degree_plan.name)")

########## Set the course passrates ##########
# set_passrates(courses, course_passrate)     # set pass rate for all courses, comment this line if computing passrate from csv file

# Compute the pass rate using UA student grade records from Spring 2017 to Fall 2019, comment this section if hardcoding passrate
real_passrate = true
csv_path = "./Student_Grades_sp17_to_fall19.csv"
set_passrates_from_csv(courses, csv_path, course_passrate)


# Set passrate for a certain course method 1
passrate = 0.5
set_passrate_for_course(courses[1], passrate)

# Set passrate for a certain course method 2
course_prefix = "MATH"
course_num = "125"
passrate = 0.5
if set_passrate_for_course(degree_plan, course_prefix, course_num, passrate)
    println(" Passrate for course $(course_prefix) $(course_num) is set to $(passrate).")
else
    println(" Course $(course_prefix) $(course_num) not found.")
end



########## Define students ##########
students = simple_students(num_students)    # Create a cohort of students for simulation

##########################################################

# run simulation
simulation = simulate(degree_plan,
                      course_attempt_limit,
                      students,
                      max_credits = max_credits,
                      performance_model = PassRate,
                      enrollment_model = Enrollment,
                      duration = duration,
                      duration_lock = duration_lock,
                      stopouts = stopouts)

# print
simulation_report(simulation, duration, course_passrate, max_credits, real_passrate)
