using CurricularAnalytics

A = Course("Introduction to Baskets", 3)
B = Course("Introduction to Baskets Lab", 1)
C = Course("Basic Basket Forms", 3)
D = Course("Advanced Basketry", 3)

add_requisite!(A, B, strict_co)
add_requisite!(A, C, pre)
add_requisite!(C, D, co)

curric = Curriculum("Basket Weaving", [A,B,C,D])

terms = Array{Term}(undef, 2)
terms[1] = Term([A,B])
terms[2] = Term([C,D])

dp = DegreePlan("2-Term Plan", curric, terms)