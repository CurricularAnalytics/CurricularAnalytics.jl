# DegreePlanAnalytics tests

@testset "DegreePlanAnalytics Tests" begin
#
# 2-term test degree plan - invalid (backwards pointing pre-requisite)
#
#    A --------* C 
#              / 
#             /  
#    B*------/
#
#    (A,C) - pre;  (C,B) - pre
#

A = Course("Introduction to Baskets", 3, institution="ACME State University", prefix="BW", num="101", canonical_name="Baskets I")
B = Course("Swimming", 3, institution="ACME State University", prefix="PE", num="115", canonical_name="Physical Education")
C = Course("Basic Basket Forms", 3, institution="ACME State University", prefix="BW", num="111", canonical_name="Baskets I")

add_requisite!(A,C,pre)
add_requisite!(C,B,pre)

curric = Curriculum("Underwater Basket Weaving", [A,B,C], institution="ACME State University", CIP="445786")

terms = Array{Term}(undef, 2)
terms[1] = Term([A,B])
terms[2] = Term([C])

dp = DegreePlan("Backwards", curric, terms)

# Test degree plan validity 
errors = IOBuffer()
@test isvalid_degree_plan(dp, errors) == false
#@test String(take!(errors)) == "\n-Invalid requisite: Basic Basket Forms in term 2 is a requisite for Swimming in term 1"

#
# 2-term test degree plan - invalid (a prerequisite points to a course in the same term)
#
#    A --------* C 
#             */ |*
#             /  |
#    B-------/   D 
#
#    (A,C) - pre; (B,C) - pre; (D,C) - pre
#

D = Course("Basic Basket Forms Lab", 1, institution="ACME State University", prefix="BW", num="111L", canonical_name="Baskets I Laboratory")

delete_requisite!(C,B) 
add_requisite!(B,C,pre)
add_requisite!(D,C,pre)

curric = Curriculum("Underwater Basket Weaving", [A,B,C,D], institution="ACME State University", CIP="445786")

terms[2] = Term([C,D])

dp = DegreePlan("Prerequisite in same term", curric, terms)

# Test degree plan validity 
errors = IOBuffer()
@test isvalid_degree_plan(dp, errors) == false
#@test String(take!(errors)) == "\n-Invalid prerequisite: Basic Basket Forms Lab in term 2 is a prerequisite for Basic Basket Forms in the same term"

#
# 2-term test degree plan - valid
# Changed prequisite in second term to co-requisite, resulting in a valid degree plan
#
#    A --------* C 
#             */ |*
#             /  |
#    B-------/   D 
#
#    (A,C) - pre; (B,C) - pre; (D,C) - strict_co
#

delete_requisite!(D,C) 
add_requisite!(D,C,strict_co)

dp = DegreePlan("Okay 2-term plan", curric, terms)

# Test degree plan validity 
errors = IOBuffer()
@test isvalid_degree_plan(dp, errors) == true

#
# 3-term test degree plan - invalid (E and F are missing from the plan)
#
#    A --------* C           E
#             */ |*
#             /  |
#    B-------/   D           F
#
#    (A,C) - pre; (B,C) - pre; (D,C) - strict_co
#

E = Course("Advanced Basketry", 3, institution="ACME State University", prefix="CS", num="300", canonical_name="Baskets II")
F = Course("Basket Materials & Decoration", 3, institution="ACME State University", prefix="BW", num="214", canonical_name="Basket Materials")

curric = Curriculum("Underwater Basket Weaving", [A,B,C,D,E,F], institution="ACME State University", CIP="445786")

terms = Array{Term}(undef, 2)
terms[1] = Term([A,B])
terms[2] = Term([C,D])

dp = DegreePlan("Plan w/ missing courses", curric, terms)

# Test degree plan validity 
errors = IOBuffer()
@test isvalid_degree_plan(dp, errors) == false
#@test String(take!(errors)) == "\n-Degree plan is missing required course: Basket Materials & Decoration\n-Degree plan is missing required course: Advanced Basketry"

# 3-term test degree plan - valid 
# added E and F to the degree plan
#
#    A --------* C           E
#             */ |*
#             /  |
#    B-------/   D           F
#
#    (A,C) - pre; (B,C) - pre; (D,C) - strict_co
#

terms = Array{Term}(undef, 3)
terms[1] = Term([A,B])
terms[2] = Term([C,D])
terms[3] = Term([E,F])

dp = DegreePlan("Okay 3-term plan", curric, terms)

# Test degree plan validity 
errors = IOBuffer()
@test isvalid_degree_plan(dp, errors) == true

end;