# DataHandler tests

@testset "DataHandler Tests" begin


# 8-vertex test curriculum - valid
#
#    A --------* C --------* E
#             */ |*
#             /  |
#    B-------/   D --------* F  
#
#    (A,C) - pre;  (C,E) -  pre; (B,C) - pre; (D,C) - co; (C,E) - pre; (D,F) - pre
#

A = Course("Introduction to Baskets", 3, institution="ACME State University", prefix="BW", num="101", canonical_name="Baskets I")
B = Course("Swimming", 3, institution="ACME State University", prefix="PE", num="115", canonical_name="Physical Education")
C = Course("Basic Basket Forms", 3, institution="ACME State University", prefix="BW", num="111", canonical_name="Baskets I")
D = Course("Basic Basket Forms Lab", 1, institution="ACME State University", prefix="BW", num="111L", canonical_name="Baskets I Laboratory")
E = Course("Advanced Basketry", 3, institution="ACME State University", prefix="CS", num="300", canonical_name="Baskets II")
F = Course("Basket Materials & Decoration", 3, institution="ACME State University", prefix="BW", num="214", canonical_name="Basket Materials")

add_requisite!(A,C,pre)
add_requisite!(B,C,pre)
add_requisite!(D,C,co)
add_requisite!(C,E,pre)
add_requisite!(D,F,pre)

curric = Curriculum("Underwater Basket Weaving", [A,B,C,D,E,F], institution="ACME State University", CIP="445786")
# Test curriculum validity 
errors = IOBuffer()
@test isvalid_curriculum(curric, errors) == true

terms = Array{Term}(undef, 3)
terms[1] = Term([A,B])
terms[2] = Term([C,D])
terms[3] = Term([E,F])

dp1 = DegreePlan("3-term UBW plan", curric, terms)

# Test degree plan validity 
errors = IOBuffer()
@test isvalid_degree_plan(dp1, errors) == true

# Write curriculum to disk
write_degree_plan(dp1, "./UBW.json")
dp2 = read_degree_plan("./UBW.json")

# Degree plans dp1 and dp2 should evaluate as the same degree plan
@test isequal(string(dp1),string(dp2))
end;