# Optimization tests

@testset "Optimization Tests" begin

# Curric: 6-vertex test curriculum - valid
#
#    A --------* C           E
#   
#       
#    B---------* D           F

#
#    (A,C) - pre; (B,D) - pre
#

A = Course("A", 3, num="1")
B = Course("B", 1, num="2")
C = Course("C", 3, num="3")
D = Course("D", 1, num="4")
E = Course("E", 3, num="5")
F = Course("F", 1, num="6")


add_requisite!(A,C,pre)
add_requisite!(B,D,pre)

curric = Curriculum("Test Curric", [A,B,C,D,E,F])

# test balance objective
dp = optimize_plan(curric, 3, 3, 12, ["Balance"])
basic_metrics(dp)
@test dp.metrics["total credit hours"] == 12
@test dp.metrics["avg. credits per term"] == 4.0
@test dp.metrics["min. credits in a term"] == 4
@test dp.metrics["max. credits in a term"] == 4
@test dp.metrics["term credit hour std. dev."] == 0
@test dp.metrics["number of terms"] == 3

# test requisite distance objective
dp = optimize_plan(curric, 3, 3, 12, ["Prereq"])
@test requisite_distance(dp) == 2

delete_requisite!(A,C)
delete_requisite!(B,D)
add_requisite!(A,C,co)
add_requisite!(B,D,co)
dp = optimize_plan(curric, 3, 3, 12, ["Prereq"])
@test requisite_distance(dp) == 0

# test toxicity objective
delete_requisite!(A,C)
delete_requisite!(B,D)
add_requisite!(A,C,pre)
add_requisite!(B,D,pre)
toxic_courses = Dict{Pair{Course,Course},Float64}()
# toxic courses should be separated
toxic_courses[A=>B] = 0.1
toxic_courses[C=>D] = 0.2
dp = optimize_plan(curric, 3, 3, 12, ["Toxicity"], toxicity_dict=toxic_courses)
@test find_term(dp, A) != find_term(dp, B)
@test find_term(dp, C) != find_term(dp, D)
# synergistic courses should be together
toxic_courses[A=>B] = -0.1
toxic_courses[C=>D] = -0.2
dp = optimize_plan(curric, 3, 3, 12, ["Toxicity"], toxicity_dict=toxic_courses)
@test find_term(dp, A) == find_term(dp, B)
@test find_term(dp, C) == find_term(dp, D)

# test multi-objective optimization
dp = optimize_plan(curric, 3, 3, 12, ["Balance", "Prereq"])
basic_metrics(dp)
@test dp.metrics["total credit hours"] == 12
@test dp.metrics["avg. credits per term"] == 4.0
@test dp.metrics["min. credits in a term"] == 4
@test dp.metrics["max. credits in a term"] == 4
@test dp.metrics["term credit hour std. dev."] == 0
@test dp.metrics["number of terms"] == 3
@test requisite_distance(dp) == 2

dp = optimize_plan(curric, 3, 3, 12, ["Prereq", "Balance"])
basic_metrics(dp)
@test dp.metrics["total credit hours"] == 12
@test dp.metrics["avg. credits per term"] == 4.0
@test dp.metrics["min. credits in a term"] == 4
@test dp.metrics["max. credits in a term"] == 4
@test dp.metrics["term credit hour std. dev."] == 0
@test dp.metrics["number of terms"] == 3
@test requisite_distance(dp) == 2

# toxic courses should be separated
toxic_courses[A=>B] = 0.1
toxic_courses[C=>D] = 0.2
dp = optimize_plan(curric, 3, 3, 12, ["Balance", "Toxicity"], toxicity_dict=toxic_courses)
@test find_term(dp, A) != find_term(dp, B)
@test find_term(dp, C) != find_term(dp, D)
# synergistic courses should be together
##toxic_courses[A=>B] = -0.1
##toxic_courses[C=>D] = -0.2
##dp = optimize_plan(curric, 3, 3, 12, ["Balance", "Toxicity"], toxicity_dict=toxic_courses)
##@test find_term(dp, A) == find_term(dp, B)
##@test find_term(dp, C) == find_term(dp, D)

# toxic courses should be separated
toxic_courses[A=>B] = 0.1
toxic_courses[C=>D] = 0.2
dp = optimize_plan(curric, 3, 3, 12, ["Toxicity", "Balance"], toxicity_dict=toxic_courses)
@test find_term(dp, A) != find_term(dp, B)
@test find_term(dp, C) != find_term(dp, D)
# synergistic courses should be together
##toxic_courses[A=>B] = -0.1
##toxic_courses[C=>D] = -0.2
##dp = optimize_plan(curric, 3, 3, 12, ["Toxicity", "Balance"], toxicity_dict=toxic_courses)
##@test find_term(dp, A) == find_term(dp, B)
##@test find_term(dp, C) == find_term(dp, D)

end

