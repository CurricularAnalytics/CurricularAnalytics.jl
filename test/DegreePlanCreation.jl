# DegreePlanCreation tests

@testset "DegreePlanCreation Tests" begin
#
# 4-course curriculum - only one possible degree plan w/ max_cpt
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

terms = bin_filling(curric, max_cpt=6)

@test terms[1].courses[1].name == "A" || terms[1].courses[1].name == "C"
@test terms[1].courses[2].name == "A" || terms[1].courses[2].name == "C"
@test terms[2].courses[1].name == "B" || terms[2].courses[1].name == "D"
@test terms[2].courses[2].name == "B" || terms[2].courses[2].name == "D"

#
# 4-course curriculum - only one possible degree plan w/ max_cpt
#
#    A          C 
#    |          |
#    |          |
#    *          *
#    B          D
#
#    (A,B) - strict_co;  (C,D) - strict_co

A = Course("A", 3, institution="ACME State", prefix="BW", num="101", canonical_name="Baskets I")
B = Course("B", 3, institution="ACME State", prefix="BW", num="201", canonical_name="Baskets II")
C = Course("C", 3, institution="ACME State", prefix="BW", num="102", canonical_name="Basket Apps I")
D = Course("D", 3, institution="ACME State", prefix="BW", num="202", canonical_name="Basket Apps II")

add_requisite!(A,B,strict_co)
add_requisite!(C,D,strict_co)

curric = Curriculum("Basket Weaving", [A,B,C,D], institution="ACME State")

terms = bin_filling(curric, max_cpt=6)

@test terms[1].courses[1].name == "A" || terms[1].courses[1].name == "B"
@test terms[1].courses[2].name == "A" || terms[1].courses[2].name == "B"
@test terms[2].courses[1].name == "C" || terms[2].courses[1].name == "D"
@test terms[2].courses[2].name == "C" || terms[2].courses[2].name == "D"

dp = create_degree_plan(curric, max_cpt=6)
@test nv(dp.curriculum.graph) == 4
@test ne(dp.curriculum.graph) == 2
for term in dp.terms
    credits = 0
    for c in term.courses
        credits += c.credit_hours
    end
    @test credits >= 3 
    @test credits <= 6
end
@test dp.terms[1].courses[1].name == "A" || dp.terms[1].courses[1].name == "B"
@test dp.terms[1].courses[2].name == "A" || dp.terms[1].courses[2].name == "B"
@test dp.terms[2].courses[1].name == "C" || dp.terms[2].courses[1].name == "D"
@test dp.terms[2].courses[2].name == "C" || dp.terms[2].courses[2].name == "D"

end;
