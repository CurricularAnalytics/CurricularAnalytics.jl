# DegreePlanCreation tests

@testset "DegreePlanCreation Tests" begin
#
# 4-course curriculum - only one minimal degree plan
#
#    A --------* B 
#               
#               
#    C --------* D
#
#    (A,B) - pre;  (C,D) - pre

A = Course("A", 3, institution="ACME State", prefix="BW", num="101", canonical_name="Baskets I")
B = Course("B", 3, institution="ACME State", prefix="BW", num="201", canonical_name="Baskets II")
C = Course("C", 3, institution="ACME State", prefix="BW", num="102", canonical_name="Basket Apps I")
D = Course("D", 3, institution="ACME State", prefix="BW", num="202", canonical_name="Basket Apps II")

add_requisite!(A,B,pre)
add_requisite!(C,D,pre)

curric = Curriculum("Basket Weaving", [A,B,C,D], institution="ACME State")

terms = bin_filling(curric, 6)

@test terms[1].courses[1].name == "A" || terms[1].courses[1].name == "C"
@test terms[1].courses[2].name == "A" || terms[1].courses[2].name == "C"
@test terms[2].courses[1].name == "B" || terms[2].courses[1].name == "D"
@test terms[2].courses[2].name == "B" || terms[2].courses[2].name == "D"

end;
