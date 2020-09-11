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

# Test Course creation 
A = Course("Introduction to Baskets", 3, institution="ACME State University", prefix="BW", num="101", canonical_name="Baskets I")
@test A.name == "Introduction to Baskets"
@test A.credit_hours == 3
@test A.prefix == "BW"
@test A.num == "101"
@test A.institution == "ACME State University"
@test A.canonical_name == "Baskets I"

# Test course_id function 
@test course_id(A.prefix, A.num, A.name, A.institution) == convert(Int, mod(hash(A.name * A.prefix * A.num * A.institution), UInt32))

B = Course("Swimming", 3, institution="ACME State University", prefix="PE", num="115", canonical_name="Physical Education")
C = Course("Basic Basket Forms", 3, institution="ACME State University", prefix="BW", num="111", canonical_name="Baskets I")
D = Course("Basic Basket Forms Lab", 1, institution="ACME State University", prefix="BW", num="111L", canonical_name="Baskets I Laboratory")
E = Course("Advanced Basketry", 3, institution="ACME State University", prefix="CS", num="300", canonical_name="Baskets II")
F = Course("Basket Materials & Decoration", 3, institution="ACME State University", prefix="BW", num="214", canonical_name="Basket Materials")
G = Course("Humanitites Elective", 3, institution="ACME State University", prefix="EGR", num="101", canonical_name="Humanitites Core")
H = Course("Technical Elective", 3, institution="ACME State University", prefix="BW", num="3xx", canonical_name="Elective")

# Test add_requisite! function
add_requisite!(A,C,pre)
add_requisite!(B,C,pre)
add_requisite!(D,C,co)
add_requisite!(C,E,pre)
add_requisite!(D,F,pre)

@test length(A.requisites) == 0
@test length(B.requisites) == 0
@test length(C.requisites) == 3
@test length(D.requisites) == 0
@test length(E.requisites) == 1
@test length(F.requisites) == 1

# Test delete_requisite! function
delete_requisite!(A,C)
@test length(C.requisites) == 2
add_requisite!(A,C,pre)

# Test Curriciulum creation 
curric = Curriculum("Underwater Basket Weaving", [A,B,C,D,E,F,G,H], institution="ACME State University", CIP="445786")
@test curric.name == "Underwater Basket Weaving"
@test curric.institution == "ACME State University"
@test curric.degree_type == BS
@test curric.system_type == semester
@test curric.CIP == "445786"
@test curric.num_courses == 8
@test curric.credit_hours == 22

# test the underlying graph
@test nv(curric.graph) == 8
@test ne(curric.graph) == 5

mapped_ids = CurricularAnalytics.map_vertex_ids(curric)
@test requisite_type(curric,mapped_ids[A.id],mapped_ids[C.id]) == pre
@test requisite_type(curric,mapped_ids[D.id],mapped_ids[C.id]) == co

@test total_credits(curric) == 22
@test course_from_vertex(curric, 1) in [A,B,C,D,E,F,G,H]
@test course_from_vertex(curric, 2) in [A,B,C,D,E,F,G,H]
@test course_from_vertex(curric, 3) in [A,B,C,D,E,F,G,H]
@test course_from_vertex(curric, 4) in [A,B,C,D,E,F,G,H]
@test course_from_vertex(curric, 5) in [A,B,C,D,E,F,G,H]
@test course_from_vertex(curric, 6) in [A,B,C,D,E,F,G,H]
@test course_from_vertex(curric, 7) in [A,B,C,D,E,F,G,H]
@test course_from_vertex(curric, 8) in [A,B,C,D,E,F,G,H]

@test course_from_id(curric, A.id) == A
@test course(curric, "BW", "101", "Introduction to Baskets", "ACME State University") == A
id = A.id
convert_ids(curric) # this should not change the ids, since the curriculum was not created from a CSV file
A.id == id

# Test CourseCollection creation 
CC = CourseCollection("Test Course Collection", 3, [A,B,C,E], institution="ACME State University")
@test CC.name == "Test Course Collection"
@test CC.credit_hours == 3
@test length(CC.courses) == 4
@test CC.institution == "ACME State University"

# Test CourseCatalog creation 
CCat = CourseCatalog("Test Course Catalog", "ACME State University", courses=[A], catalog=Dict([(B.id=>B),C.id=>C]), date_range=(Date(2019,8), Date(2020,7,31)))
@test CCat.name == "Test Course Catalog"
@test CCat.institution == "ACME State University"
@test length(CCat.catalog) == 3

# Test add_course! functions
add_course!(CCat, [D])
@test length(CCat.catalog) == 4
add_course!(CCat, [E,F])
@test length(CCat.catalog) == 6
@test is_duplicate(CCat, A) == true
@test is_duplicate(CCat, G) == false
@test (CCat.date_range[2] - CCat.date_range[1]) == Dates.Day(365)
@test A == course(CCat, "BW", "101", "Introduction to Baskets")

# Test DegreePlan creation 
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