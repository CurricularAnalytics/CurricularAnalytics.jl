# DataTypes tests
@testset "DataTypes Tests" begin

# 8-vertex test curriculum - valid
#
#    A --------* C --------* E           G
#             */ |*
#             /  |
#    B-------/   D --------* F           H
#
#    (A,C) - pre;  (C,E) -  pre; (B,C) - pre; (D,C) - co; (C,E) - pre; (D,F) - pre
#

# Test course creation 
A = Course("Introduction to Baskets", 3, institution="ACME State University", prefix="BW", num="101", canonical_name="Baskets I")
@test A.name == "Introduction to Baskets"
@test A.credit_hours == 3
@test A.prefix == "BW"
@test A.num == "101"
@test A.institution == "ACME State University"
@test A.canonical_name == "Baskets I"

# Test curriciulum creation 
B = Course("Swimming", 3, institution="ACME State University", prefix="PE", num="115", canonical_name="Physical Education")
C = Course("Basic Basket Forms", 3, institution="ACME State University", prefix="BW", num="111", canonical_name="Baskets I")
D = Course("Basic Basket Forms Lab", 1, institution="ACME State University", prefix="BW", num="111L", canonical_name="Baskets I Laboratory")
E = Course("Advanced Basketry", 3, institution="ACME State University", prefix="CS", num="300", canonical_name="Baskets II")
F = Course("Basket Materials & Decoration", 3, institution="ACME State University", prefix="BW", num="214", canonical_name="Basket Materials")
G = Course("Humanitites Elective", 3, institution="ACME State University", prefix="EGR", num="101", canonical_name="Humanitites Core")
H = Course("Technical Elective", 3, institution="ACME State University", prefix="BW", num="3xx", canonical_name="Elective")

add_requisite!(A,C,pre)
add_requisite!(B,C,pre)
add_requisite!(D,C,co)
add_requisite!(C,E,pre)
add_requisite!(D,F,pre)

curric = Curriculum("Underwater Basket Weaving", [A,B,C,D,E,F,G,H], institution="ACME State University", CIP="445786")
@test curric.name == "Underwater Basket Weaving"
@test curric.institution == "ACME State University"
@test curric.degree_type == BS
@test curric.system_type == semester
@test curric.CIP == "445786"
@test curric.num_courses == 8
@test curric.credit_hours == 22

# Test degree plan creation 
terms = Array{Term}(undef, 4)
terms[1] = Term([A,B])
terms[2] = Term([C,D])
terms[3] = Term([E,F])
terms[4] = Term([G,H])
dp = DegreePlan("2019 Plan", curric, terms)
@test dp.name == "2019 Plan"
@test dp.curriculum === curric  # tests that they're the same object in memory
@test dp.num_terms == 4
@test dp.credit_hours == 22

end;