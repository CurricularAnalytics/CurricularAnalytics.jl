
# RequirementsAnalytics tests

@testset "RequirementsAnalytics Tests" begin

C1 = Course("Math 1", 3)
C2 = Course("Math 2", 3)
C3 = Course("English", 3)
C4 = Course("Humanities 1", 1)
C5 = Course("Humanities 2", 3)
C6 = Course("Fine Arts", 3)
C7 = Course("Major 1", 3)
C8 = Course("Major 2", 3)
C9 = Course("Major 3", 3)
C10 = Course("Major 4", 3)
C11 = Course("Major 5", 3)
C12 = Course("Major 6", 3)
C13 = Course("Major 7", 3)
C14 = Course("Major 8", 3)

math_courses = Array{Pair{Course, Grade},1}()
push!(math_courses, C1 => grade("D"))  # must earn a D or better grade in course C1
push!(math_courses, C2 => grade("D"))
dr1 = CourseSet("Math", 6, math_courses, description="General Education Mathematics Requirement", double_count = true) 

dr2 = CourseSet("English", 3, [C3 => grade("D")], description="General Education English Requirement", double_count = true)

humanities_courses = Array{Pair{Course, Grade},1}()
push!(humanities_courses, C4 => grade("D"))
push!(humanities_courses, C5 => grade("D"))
dr3 = CourseSet("Humanities Requirement", 4, humanities_courses, description="General Education Humanities Requirement", double_count = true)

gen_ed_reqs = Array{AbstractRequirement,1}()
push!(gen_ed_reqs, dr1, dr2, dr3)
dr4 = RequirementSet("Gen. Ed. Core", 13, gen_ed_reqs, description="General Education Requirements")

dr5 = CourseSet("Major Requirement #1", 3, [C1 => grade("C")], description="1st Major Requirement")
dr6 = CourseSet("Major Requirement #2", 3, [C8 => grade("C")], description="2nd Major Requirement")
dr7 = CourseSet("Major Requirement #3", 3, [C9 => grade("C")], description="3rd Major Requirement")
dr8 = CourseSet("Major Requirement #4", 3, [C10 => grade("C")], description="4th Major Requirement")

dr9 = CourseSet("Track 1", 6, [C11 => grade("C"), C12 => grade("C")])
dr10 = CourseSet("Track 2", 6, [C13 => grade("C"), C14 => grade("C")])

track_reqs = Array{AbstractRequirement,1}()
push!(track_reqs, dr9, dr10)
dr11 = RequirementSet("Concentration", 6, track_reqs, description="Concentration Requirements", satisfy=1)

electives = Array{Pair{Course, Grade},1}()
push!(electives, C11 => grade("D"))
push!(electives, C12 => grade("D"))
push!(electives, C13 => grade("D"))
push!(electives, C14 => grade("D"))
dr12 = CourseSet("Program Electives", 9, electives, description="Program Electives")
#dr13 = RequirementSet("No Track Electives/Major Requirement Double Count", 6, [dr11, dr12], satisfy=1)

program_reqs = Array{AbstractRequirement,1}()
push!(program_reqs, dr4, dr5, dr6, dr7, dr8, dr11, dr12)
#push!(program_reqs, dr4, dr5, dr6, dr7, dr8, dr11, dr12, dr13)
program_requirements = RequirementSet("Program Requirements", 40, program_reqs, description="Degree Requirements for the BS Program")

errors = IOBuffer()
@test is_valid(program_requirements, errors) == true
@test is_valid(dr4, errors) == true

bad_program_requirements = RequirementSet("Program Requirements", 41, program_reqs, description="Degree Requirements for the BS Program")
@test is_valid(bad_program_requirements, errors) == false

bad_dr3 = CourseSet("Humanities Requirement", 6, humanities_courses, description="General Education Humanities Requirement", double_count = true)
@test is_valid(bad_dr3, errors) == false

end