# DegreePlanAnalytics tests

@testset "DegreePlanAnalytics Tests" begin
#
A = Course("A", 3)
B = Course("B", 1)
C = Course("C", 3)
D = Course("D", 1)
E = Course("E", 3)
F = Course("F", 3)

add_requisite!(A,E,pre)
add_requisite!(A,C,pre)
add_requisite!(B,E,pre)
add_requisite!(B,F,pre)
add_requisite!(D,E,pre)
add_requisite!(E,E,strict_co)

curric = Curriculum("Test Curric", [A,B,C,D,E,F], sortby_ID=false)
terms = Array{Term}(undef, 3)
terms[1] = Term([A,B])
terms[2] = Term([C,D])
terms[3] = Term([E,F])
dp = DegreePlan("Test Plan", curric, terms)

# Test requisite_distance(course) 
@test requisite_distance(dp, A) == 0
@test requisite_distance(dp, B) == 0
@test requisite_distance(dp, C) == 1
@test requisite_distance(dp, D) == 0
@test requisite_distance(dp, E) == 5
@test requisite_distance(dp, F) == 2
@test requisite_distance(dp) == 8
end;