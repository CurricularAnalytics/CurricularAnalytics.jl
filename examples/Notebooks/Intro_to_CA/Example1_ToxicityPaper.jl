## Curriculum assoicated with example curricula1 
##Degree Plan Optimization with Objective of Toxic Course Combination Avoidance,
##Gregory L. Heileman†, Orhan Abar‡, Mehmet Gokhan Bakal‡, and William G. Thompson-Arjona†
##†Department of Electrical & Computer Engineering
##‡Department of Computer Science

## 6 courses 2 terms not optimized 


using CurricularAnalytics

# create the courses
c = Array{Course}(undef, 6)

# term 1
c[1] = Course("C1", 3)
c[2] = Course("C3", 3)
c[3] = Course("C6", 3)

# term 3
c[4] = Course("C2", 3)
c[5] = Course("C4", 3)
c[6] = Course("C5", 3)

# term 1
#add_requisite!(c[1],c[2],pre)
#add_requisite!(c[1],c[3],pre)

# term 2
#add_requisite!(c[2],c[4],pre)

curric = Curriculum("Example Curricula c1", c)

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

terms = Array{Term}(undef, 2)
terms[1] = Term([c[1],c[2],c[3]])
terms[2] = Term([c[4],c[5],c[6]])



dp = DegreePlan("Example Not Optomized Curricula ", curric, terms)

basic_metrics(dp)
dp.metrics
visualize(dp)