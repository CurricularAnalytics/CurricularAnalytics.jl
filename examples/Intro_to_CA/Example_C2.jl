## Curriculum assoicated with curricula c2, page 9, Heileman, G. L., Slim, A., Hickman, M.,  and Abdallah, C. T. (2018). 
##Curricular Analytics: A Framework for Quantifying the Impact of Curricular Reforms and Pedagogical Innovations 
##https://arxiv.org/pdf/1811.09676.pdf

using CurricularAnalytics

# create the courses
c = Array{Course}(undef, 4)

# term 1
c[1] = Course("Calculus 1", 3, prefix = "MATH ", num = "1011")
c[2] = Course("Physics I: Mechanics & Heat", 3, prefix = "PHYS", num = "1112")

# term 2
c[3] = Course("Calculus 2", 3, prefix = "MATH", num = "1920")

# term 3
c[4] = Course("Circuits 1", 3, prefix = "EE", num = "2200")
# test
# term 2
add_requisite!(c[1],c[3],pre)
add_requisite!(c[2],c[3],pre)

# term 3
add_requisite!(c[3],c[4],pre)

curric = Curriculum("Example Curricula C2", c)

errors = IOBuffer()
if isvalid_curriculum(curric, errors)
    println("Curriculum $(curric.name) is valid")
    println("  delay factor = $(delay_factor(curric))")
    println("  blocking factor = $(blocking_factor(curric))")
    println("  centrality factor = $(centrality(curric))")
    println("  curricular complexity = $(complexity(curric))")
else
    println("Curriculum $(curric.name) is not valid:")
    print(String(take!(errors)))
end

terms = Array{Term}(undef, 3)
terms[1] = Term([c[1],c[2]])
terms[2] = Term([c[3]])
terms[3] = Term([c[4]])


dp = DegreePlan("Example Curricula c2", curric, terms)

basic_metrics(dp)
dp.metrics
visualize(dp)