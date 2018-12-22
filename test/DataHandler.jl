# DataHandler tests

@testset "DataHandler Tests" begin

# Test the data file format used for curriculum and degree plans
curric = read_csv("./curriculum.csv")
@test curric.name == "Underwater Basket Weaving"
@test curric.institution == "ACME State University"
@test curric.degree_type == AA
@test curric.system_type == semester
@test curric.CIP == "445786"
@test length(curric.courses) == 12
@test curric.num_courses == 12
@test curric.credit_hours == 35
# courses
@test curric.courses[1].name == "Introduction to Baskets"
@test curric.courses[1].id == 1
@test curric.courses[1].credit_hours == 3
@test curric.courses[1].prefix == "BW"
@test curric.courses[1].num == "101"
@test curric.courses[1].institution == "ACME State University"
@test curric.courses[1].canonical_name == "Baskets I"
@test length(curric.courses[1].requisites) == 0
#
@test curric.courses[2].name == "Swimming"
@test curric.courses[2].id == 2
@test curric.courses[2].credit_hours == 3
@test curric.courses[2].prefix == "PE"
@test curric.courses[2].num == "115"
@test curric.courses[2].institution == "ACME State University"
@test curric.courses[2].canonical_name == "Physical Education"
@test length(curric.courses[2].requisites) == 0
#
@test curric.courses[3].name == "Introductory Calculus w/ Basketry Applications"
@test curric.courses[3].id == 3
@test curric.courses[3].credit_hours == 4
@test curric.courses[3].curric.prefix == "MA"
@test curric.courses[3].num == "116"
@test curric.courses[3].institution == "ACME State University"
@test curric.courses[3].canonical_name == "Calculus I"
@test curric.courses[3].requisites[13] == pre
#
@test curric.courses[4].name == "Basic Basket Forms"
@test curric.courses[4].id == 4
@test curric.courses[4].credit_hours == 3
@test curric.courses[4].prefix == "BW"
@test curric.courses[4].num == "111"
@test curric.courses[4].institution == "ACME State University"
@test curric.courses[4].canonical_name == "Baskets II"
@test curric.courses[4].requisites[1] == pre
@test curric.courses[4].requisites[5] == strict_co
#
@test curric.courses[5].name == "Basic Basket Forms Lab"
@test curric.courses[5].id == 5
@test curric.courses[5].credit_hours == 1
@test curric.courses[5].prefix == "BW"
@test curric.courses[5].num == "111L"
@test curric.courses[5].institution == "ACME State University"
@test curric.courses[5].canonical_name == "Baskets II Laboratory"
@test length(curric.courses[5].requisites) == 0
#
@test curric.courses[6].name == "Advanced Basketry"
@test curric.courses[6].id == 6
@test curric.courses[6].credit_hours == 3
@test curric.courses[6].prefix == "BW"
@test curric.courses[6].num == "201"
@test curric.courses[6].institution == "ACME State University"
@test curric.courses[6].canonical_name == "Baskets III"
@test curric.courses[6].requisites[4] == pre
@test curric.courses[6].requisites[5] == pre
@test curric.courses[6].requisites[3] == co
#
@test curric.courses[7].name == "Basket Materials & Decoration"
@test curric.courses[7].id == 7
@test curric.courses[7].credit_hours == 3
@test curric.courses[7].prefix == "BW"
@test curric.courses[7].num == "214"
@test curric.courses[7].institution == "ACME State University"
@test curric.courses[7].canonical_name == "Basket Materials"
@test curric.courses[7].requisites[1] == pre
#
@test curric.courses[8].name == "Underwater Weaving"
@test curric.courses[8].id == 8
@test curric.courses[8].credit_hours == 3
@test curric.courses[8].prefix == "BW"
@test curric.courses[8].num == "301"
@test curric.courses[8].institution == "ACME State University"
@test curric.courses[8].canonical_name == "Baskets IV"
@test curric.courses[8].requisites[2] == pre
@test curric.courses[8].requisites[7] == co
#
@test curric.courses[9].name == "Humanitites Elective"
@test curric.courses[9].id == 9
@test curric.courses[9].credit_hours == 3
@test curric.courses[9].institution == "ACME State University"
@test length(curric.courses[9].requisites) == 0
#
@test curric.courses[10].name == "Social Sciences Elective"
@test curric.courses[10].id == 10
@test curric.courses[10].credit_hours == 3
@test curric.courses[11].institution == "ACME State University"
@test length(curric.courses[10].requisites) == 0
#
@test curric.courses[11].name == "Technical Elective"
@test curric.courses[11].id == 11
@test curric.courses[11].credit_hours == 3
@test curric.courses[11].institution == "ACME State University"
@test length(curric.courses[11].requisites) == 0
#
@test curric.courses[12].name == "General Elective"
@test curric.courses[12].id == 12
@test curric.courses[12].credit_hours == 3
@test curric.courses[12].institution == "ACME State University"
@test length(curric.courses[12].requisites) == 0
# TODO: add learning outcomes

dp = read_csv(./"degree_plan.csv")
@test dp.name == "4-Term Plan"
@test dp.curriculum.name == "Underwater Basket Weaving"
@test dp.curriculum.institution == "ACME State University"
@test dp.curriculum.degree_type == AA
@test dp.curriculum.system_type == semester
@test dp.curriculum.CIP == "445786"
@test length(dp.curriculum.courses) == 12
@test dp.num_terms == 4
@test dp.credit_hours == 42
@test length(dp.additional_courses) == 3
# courses
@test curric.courses[1].name == "Introduction to Baskets"
@test curric.courses[1].id == 1
@test curric.courses[1].credit_hours == 3
@test curric.courses[1].prefix == "BW"
@test curric.courses[1].num == "101"
@test curric.courses[1].institution == "ACME State University"
@test curric.courses[1].canonical_name == "Baskets I"
@test length(curric.courses[1].requisites) == 0
#
@test curric.courses[2].name == "Swimming"
@test curric.courses[2].id == 2
@test curric.courses[2].credit_hours == 3
@test curric.courses[2].prefix == "PE"
@test curric.courses[2].num == "115"
@test curric.courses[2].institution == "ACME State University"
@test curric.courses[2].canonical_name == "Physical Education"
@test length(curric.courses[2].requisites) == 0
#
@test curric.courses[3].name == "Introductory Calculus w/ Basketry Applications"
@test curric.courses[3].id == 3
@test curric.courses[3].credit_hours == 4
@test curric.courses[3].curric.prefix == "MA"
@test curric.courses[3].num == "116"
@test curric.courses[3].institution == "ACME State University"
@test curric.courses[3].canonical_name == "Calculus I"
@test curric.courses[3].requisites[13] == pre
#
@test curric.courses[4].name == "Basic Basket Forms"
@test curric.courses[4].id == 4
@test curric.courses[4].credit_hours == 3
@test curric.courses[4].prefix == "BW"
@test curric.courses[4].num == "111"
@test curric.courses[4].institution == "ACME State University"
@test curric.courses[4].canonical_name == "Baskets II"
@test curric.courses[4].requisites[1] == pre
@test curric.courses[4].requisites[5] == strict_co
#
@test curric.courses[5].name == "Basic Basket Forms Lab"
@test curric.courses[5].id == 5
@test curric.courses[5].credit_hours == 1
@test curric.courses[5].prefix == "BW"
@test curric.courses[5].num == "111L"
@test curric.courses[5].institution == "ACME State University"
@test curric.courses[5].canonical_name == "Baskets II Laboratory"
@test length(curric.courses[5].requisites) == 0
#
@test curric.courses[6].name == "Advanced Basketry"
@test curric.courses[6].id == 6
@test curric.courses[6].credit_hours == 3
@test curric.courses[6].prefix == "BW"
@test curric.courses[6].num == "201"
@test curric.courses[6].institution == "ACME State University"
@test curric.courses[6].canonical_name == "Baskets III"
@test curric.courses[6].requisites[4] == pre
@test curric.courses[6].requisites[5] == pre
@test curric.courses[6].requisites[3] == co
#
@test curric.courses[7].name == "Basket Materials & Decoration"
@test curric.courses[7].id == 7
@test curric.courses[7].credit_hours == 3
@test curric.courses[7].prefix == "BW"
@test curric.courses[7].num == "214"
@test curric.courses[7].institution == "ACME State University"
@test curric.courses[7].canonical_name == "Basket Materials"
@test curric.courses[7].requisites[1] == pre
#
@test curric.courses[8].name == "Underwater Weaving"
@test curric.courses[8].id == 8
@test curric.courses[8].credit_hours == 3
@test curric.courses[8].prefix == "BW"
@test curric.courses[8].num == "301"
@test curric.courses[8].institution == "ACME State University"
@test curric.courses[8].canonical_name == "Baskets IV"
@test curric.courses[8].requisites[2] == pre
@test curric.courses[8].requisites[7] == co
#
@test curric.courses[9].name == "Humanitites Elective"
@test curric.courses[9].id == 9
@test curric.courses[9].credit_hours == 3
@test curric.courses[9].institution == "ACME State University"
@test length(curric.courses[9].requisites) == 0
#
@test curric.courses[10].name == "Social Sciences Elective"
@test curric.courses[10].id == 10
@test curric.courses[10].credit_hours == 3
@test curric.courses[11].institution == "ACME State University"
@test length(curric.courses[10].requisites) == 0
#
@test curric.courses[11].name == "Technical Elective"
@test curric.courses[11].id == 11
@test curric.courses[11].credit_hours == 3
@test curric.courses[11].institution == "ACME State University"
@test length(curric.courses[11].requisites) == 0
#
@test curric.courses[12].name == "General Elective"
@test curric.courses[12].id == 12
@test curric.courses[12].credit_hours == 3
@test curric.courses[12].institution == "ACME State University"
@test length(curric.courses[12].requisites) == 0
# additional courses
@test dp.additional_courses[1].name == "Precalculus w/ Basketry Applications"
@test dp.additional_courses[1].id == 13
@test dp.additional_courses[1].credit_hours == 3
@test dp.additional_courses[1].prefix == "MA"
@test dp.additional_courses[1].num == "110"
@test dp.additional_courses[1].institution == "ACME State University"
@test dp.additional_courses[1].canonical_name == "Precalculus"
@test dp.additional_courses[1].requisites[14] == pre
#
@test dp.additional_courses[1].name == "College Algebra"
@test dp.additional_courses[1].id == 14
@test dp.additional_courses[1].credit_hours == 3
@test dp.additional_courses[1].prefix == "MA"
@test dp.additional_courses[1].num == "102"
@test dp.additional_courses[1].institution == "ACME State University"
@test dp.additional_courses[1].canonical_name == "College Algebra"
@test dp.additional_courses[1].requisites[15] == strict_co
#
@test dp.additional_courses[1].name == "College Algebra Studio"
@test dp.additional_courses[1].id == 15
@test dp.additional_courses[1].credit_hours == 1
@test dp.additional_courses[1].prefix == "MA"
@test dp.additional_courses[1].num == "102S"
@test dp.additional_courses[1].institution == "ACME State University"
@test dp.additional_courses[1].canonical_name == "College Algebra Recitation"
@test length(dp.additional_courses[1].requisites[15]) == 0

# Create a curriculum and degree plan, and test read/write invariance for both
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

curric1 = Curriculum("Underwater Basket Weaving", [A,B,C,D,E,F], institution="ACME State University", CIP="445786")
# Write curriculum to disk
#@test write_csv(curric1, "UBW-curric.csv") == true
#curric2 = read_csv_new("examples/UBW-curric.csv")
#@test string(curric1) == string(curric2)  # read/write invariance test

terms = Array{Term}(undef, 3)
terms[1] = Term([A,B])
terms[2] = Term([C,D])
terms[3] = Term([E,F])

dp1 = DegreePlan("3-term UBW plan", curric1, terms)
# Write degree plan to disk
@test write_csv(dp1, "UBW-degree-plan.csv") == true
dp2 = read_csv_new("UBW-degree-plan.csv")
@test string(dp1) == string(dp2)  # read/write invariance test

end;
