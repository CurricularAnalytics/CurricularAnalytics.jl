# CurricularAnalytics tests

@testset "CurricularAnalytics Tests" begin

# Curric1: 1-vertex test curriculum - invalid (a one-vertex cycle)
#
#    A *---
#    |     |
#    |     |
#     ------
#

A = Course("A", 3)

add_requisite!(A,A,pre)

curric = Curriculum("Cycle", [A])

# Test curriculum validity 
errors = IOBuffer()
@test isvalid_curriculum(curric, errors) == false
#@test String(take!(errors)) == "\nCurriculum Cycle contains the following requisite cycles:\n(A)\n"

# Curric1: 4-vertex test curriculum - invalid (contains a extraneous prerequisite)
#
#    A --------* C
#    |        */ |*
#    |*       /  |
#    B ------/   D
#
#    Course A is an extraneous prerequisite for course C

a = Course("A", 3)
b = Course("B", 3)
c = Course("C", 3)
d = Course("D", 1)

add_requisite!(a,c,pre)
add_requisite!(b,c,pre)
add_requisite!(d,c,co)
add_requisite!(a,b,pre)

curric = Curriculum("Extraneous", [a,b,c,d])

# Test curriculum validity 
errors = IOBuffer()
@test isvalid_curriculum(curric, errors) == false
#@test String(take!(errors)) == "\nCurriculum Extraneous contains the following extraneous requisites:\nCourse C has redundant requisite: A"

# 8-vertex test curriculum - valid
#
#    A --------* C --------* E           G
#             */ |*
#             /  |
#    B-------/   D --------* F           H
#
#    (A,C) - pre;  (C,E) -  pre; (B,C) - pre; (D,C) - co; (C,E) - pre; (D,F) - pre
#

A = Course("Introduction to Baskets", 3, institution="ACME State University", prefix="BW", num="101", canonical_name="Baskets I")
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

# Test curriculum validity 
errors = IOBuffer()
@test isvalid_curriculum(curric, errors) == true

# Test analytics 
@test delay_factor(curric) == (19.0, [3.0, 3.0, 3.0, 3.0, 3.0, 2.0, 1.0, 1.0])
@test blocking_factor(curric) == (8, [2, 2, 1, 3, 0, 0, 0, 0])
@test centrality(curric) == (9, [0, 0, 9, 0, 0, 0, 0, 0])
@test complexity(curric) == (27.0, [5.0, 5.0, 4.0, 6.0, 3.0, 2.0, 1.0, 1.0])

# Curric: 7-vertex test curriculum - valid
#
#    A --------* C --------* E
#    |           |
#    |*          |*
#    B---------* D --------* F
#                |        /*
#                |*      /
#                G------/
#
#    (A,B) - co; (A,C) - pre; (B,D) - pre; (C,D) -  co;
#    (C,E) - pre; (D,F) - pre; (D,G) - co; (G,F) - pre
#

A = Course("A", 3)
B = Course("B", 1)
C = Course("C", 3)
D = Course("D", 1)
E = Course("E", 3)
F = Course("F", 3)
G = Course("G", 3)

add_requisite!(A,B,co)
add_requisite!(A,C,pre)
add_requisite!(B,D,pre)
add_requisite!(C,D,co)
add_requisite!(C,E,pre)
add_requisite!(D,F,pre)
add_requisite!(D,G,co)
add_requisite!(G,F,pre)

curric = Curriculum("Postmodern Basket Weaving", [A,B,C,D,E,F,G])

# Test curriculum validity 
errors = IOBuffer()
@test isvalid_curriculum(curric, errors) == true

# Test analytics 
@test delay_factor(curric) == (32.0, [5.0, 5.0, 4.0, 5.0, 3.0, 5.0, 5.0])
@test blocking_factor(curric) == (16, [6, 3, 4, 2, 0, 0, 1])
@test centrality(curric) == (49, [0, 9, 12, 18, 0, 0, 10])
@test complexity(curric) == (48.0, [11.0, 8.0, 8.0, 7.0, 3.0, 5.0, 6.0])


end;