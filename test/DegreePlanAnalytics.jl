# DegreePlanAnalytics tests

# 6-vertex test curriculum - valid
#       
#     /---------------------*\
#    A --------* C    /-----* E          
#              /-----/      */|*  
#             /  |----------/ | 
#    B-------/   D            F           
#     \---------------------*/
#
#    (A,C) - pre;  (A,E) -  pre; (B,E) - pre; (B,F) - pre; (D,E) - co; (F,E) - strict_co

@testset "DegreePlanAnalytics Tests" begin

A = Course("A", 3)
B = Course("B", 1)
C = Course("C", 2)
D = Course("D", 1)
E = Course("E", 4)
F = Course("F", 1)

add_requisite!(A,E,pre)
add_requisite!(A,C,pre)
add_requisite!(B,E,pre)
add_requisite!(B,F,pre)
add_requisite!(D,E,co)
add_requisite!(F,E,strict_co)

curric = Curriculum("Test Curric", [A,B,C,D,E,F])
terms = Array{Term}(undef, 3)
terms[1] = Term([A,B])
terms[2] = Term([C,D])
terms[3] = Term([E,F])
dp = DegreePlan("Test Plan", curric, terms)

# Test requisite_distance(plan, course) and requisite_distance(plan)
@test requisite_distance(dp, A) == 0
@test requisite_distance(dp, B) == 0
@test requisite_distance(dp, C) == 1
@test requisite_distance(dp, D) == 0
@test requisite_distance(dp, E) == 5
@test requisite_distance(dp, F) == 2
@test requisite_distance(dp) == 8

# Test basic basic_metrics(plan)
basic_metrics(dp)
@test dp.metrics["total credit hours"] == 12
@test dp.metrics["avg. credits per term"] == 4.0
@test dp.metrics["min. credits in a term"] == 3
@test dp.metrics["max. credits in a term"] == 5
@test dp.metrics["term credit hour std. dev."] ≈ 0.816497 atol=1e-5
@test dp.metrics["number of terms"] == 3
@test dp.metrics["min. credit term"] == 2
@test dp.metrics["max. credit term"] == 3

end;