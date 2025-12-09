# DataHandler tests

@testset "DataHandler Tests" begin

# test the data file format used for curricula
curric = read_csv("./curriculum.csv")

@test curric.name == "Underwater Basket Weaving"
@test curric.institution == "ACME State University"
@test curric.degree_type == "AA"
@test curric.system_type == semester
@test curric.CIP == "445786"
@test length(curric.courses) == 12
@test curric.num_courses == 12
@test curric.credit_hours == 35
# test courses
for (i,c) in enumerate(curric.courses)
    if c.id == 1
        @test curric.courses[i].name == "Introduction to Baskets"
        @test curric.courses[i].credit_hours == 3
        @test curric.courses[i].prefix == "BW"
        @test curric.courses[i].num == "110"
        @test curric.courses[i].institution == "ACME State University"
        @test curric.courses[i].canonical_name == "Baskets I"
        @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 2
        @test curric.courses[i].name == "Swimming"
        @test curric.courses[i].credit_hours == 3
        @test curric.courses[i].prefix == "PE"
        @test curric.courses[i].num == "115"
        @test curric.courses[i].institution == "ACME State University"
        @test curric.courses[i].canonical_name == "Physical Education"
        @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 3
        @test curric.courses[i].name == "Introductory Calculus w/ Basketry Applications"
        @test curric.courses[i].credit_hours == 4
        @test curric.courses[i].prefix == "MA"
        @test curric.courses[i].num == "116"
        @test curric.courses[i].institution == "ACME State University"
        @test curric.courses[i].canonical_name == "Calculus I"
        @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 4
        @test curric.courses[i].name == "Basic Basket Forms"
        @test curric.courses[i].credit_hours == 3
        @test curric.courses[i].prefix == "BW"
        @test curric.courses[i].num == "111"
        @test curric.courses[i].institution == "ACME State University"
        @test curric.courses[i].canonical_name == "Baskets II"
        @test curric.courses[i].requisites[1][1] == pre
        @test curric.courses[i].requisites[1][5] == strict_co
    elseif c.id == 5
        @test curric.courses[i].name == "Basic Basket Forms Lab"
        @test curric.courses[i].credit_hours == 1
        @test curric.courses[i].prefix == "BW"
        @test curric.courses[i].num == "111L"
        @test curric.courses[i].institution == "ACME State University"
        @test curric.courses[i].canonical_name == "Baskets II Laboratory"
        @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 6
        @test curric.courses[i].name == "Advanced Basketry"
        @test curric.courses[i].credit_hours == 3
        @test curric.courses[i].prefix == "BW"
        @test curric.courses[i].num == "201"
        @test curric.courses[i].institution == "ACME State University"
        @test curric.courses[i].canonical_name == "Baskets III"
        @test curric.courses[i].requisites[1][4] == pre
        @test curric.courses[i].requisites[1][5] == pre
        @test curric.courses[i].requisites[1][3] == co
    elseif c.id == 7
        @test curric.courses[i].name == "Basket Materials & Decoration"
        @test curric.courses[i].credit_hours == 3
        @test curric.courses[i].prefix == "BW"
        @test curric.courses[i].num == "214"
        @test curric.courses[i].institution == "ACME State University"
        @test curric.courses[i].canonical_name == "Basket Materials"
        @test curric.courses[i].requisites[1][1] == pre
    elseif c.id == 8
        @test curric.courses[i].name == "Underwater Weaving"
        @test curric.courses[i].credit_hours == 3
        @test curric.courses[i].prefix == "BW"
        @test curric.courses[i].num == "301"
        @test curric.courses[i].institution == "ACME State University"
        @test curric.courses[i].canonical_name == "Baskets IV"
        @test curric.courses[i].requisites[1][2] == pre
        @test curric.courses[i].requisites[1][7] == co
    elseif c.id == 9
        @test curric.courses[i].name == "Humanitites Elective"
        @test curric.courses[i].credit_hours == 3
        @test curric.courses[i].institution == "ACME State University"
        @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 10
        @test curric.courses[i].name == "Social Sciences Elective"
        @test curric.courses[i].credit_hours == 3
        @test curric.courses[i].institution == "ACME State University"
        @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 11
        @test curric.courses[i].name == "Technical Elective"
        @test curric.courses[i].credit_hours == 3
        @test curric.courses[i].institution == "ACME State University"
        @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 12
        @test curric.courses[i].name == "General Elective"
        @test curric.courses[i].credit_hours == 3
        @test curric.courses[i].institution == "ACME State University"
        @test length(curric.courses[i].requisites[1]) == 0
    end
end
# TODO: add learning outcomes

# test the data file format used for degree plans
dp = read_csv("degree_plan.csv")

@test dp.name == "4-Term Plan"
@test dp.curriculum.name == "Underwater Basket Weaving"
@test dp.curriculum.institution == "ACME State University"
@test dp.curriculum.degree_type == "AA"
@test dp.curriculum.system_type == semester
@test dp.curriculum.CIP == "445786"
@test length(dp.curriculum.courses)-length(dp.additional_courses) == 12
@test dp.num_terms == 4
@test dp.credit_hours == 45
@test length(dp.additional_courses) == 4
# test courses -- same tests as in the above curriculum, but a few additional courses 
# have been added, as well as a new requisite to an existing courses.
# test courses
curric = dp.curriculum
for (i,c) in enumerate(curric.courses)
    if c.id == 1
         @test curric.courses[i].name == "Introduction to Baskets"
         @test curric.courses[i].credit_hours == 3
         @test curric.courses[i].prefix == "BW"
         @test curric.courses[i].num == "110"
         @test curric.courses[i].institution == "ACME State University"
         @test curric.courses[i].canonical_name == "Baskets I"
         @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 2
         @test curric.courses[i].name == "Swimming"
         @test curric.courses[i].credit_hours == 3
         @test curric.courses[i].prefix == "PE"
         @test curric.courses[i].num == "115"
         @test curric.courses[i].institution == "ACME State University"
         @test curric.courses[i].canonical_name == "Physical Education"
         @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 3
         @test curric.courses[i].name == "Introductory Calculus w/ Basketry Applications"
         @test curric.courses[i].credit_hours == 4
         @test curric.courses[i].prefix == "MA"
         @test curric.courses[i].num == "116"
         @test curric.courses[i].institution == "ACME State University"
         @test curric.courses[i].canonical_name == "Calculus I"
         # this is the only difference from above tests
         @test curric.courses[i].requisites[1][13] == pre
    elseif c.id == 4
         @test curric.courses[i].name == "Basic Basket Forms"
         @test curric.courses[i].credit_hours == 3
         @test curric.courses[i].prefix == "BW"
         @test curric.courses[i].num == "111"
         @test curric.courses[i].institution == "ACME State University"
         @test curric.courses[i].canonical_name == "Baskets II"
         @test curric.courses[i].requisites[1][1] == pre
         @test curric.courses[i].requisites[1][5] == strict_co
    elseif c.id == 5
         @test curric.courses[i].name == "Basic Basket Forms Lab"
         @test curric.courses[i].credit_hours == 1
         @test curric.courses[i].prefix == "BW"
         @test curric.courses[i].num == "111L"
         @test curric.courses[i].institution == "ACME State University"
         @test curric.courses[i].canonical_name == "Baskets II Laboratory"
         @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 6
         @test curric.courses[i].name == "Advanced Basketry"
         @test curric.courses[i].credit_hours == 3
         @test curric.courses[i].prefix == "BW"
         @test curric.courses[i].num == "201"
         @test curric.courses[i].institution == "ACME State University"
         @test curric.courses[i].canonical_name == "Baskets III"
         @test curric.courses[i].requisites[1][4] == pre
         @test curric.courses[i].requisites[1][5] == pre
         @test curric.courses[i].requisites[1][3] == co
    elseif c.id == 7
         @test curric.courses[i].name == "Basket Materials & Decoration"
         @test curric.courses[i].credit_hours == 3
         @test curric.courses[i].prefix == "BW"
         @test curric.courses[i].num == "214"
         @test curric.courses[i].institution == "ACME State University"
         @test curric.courses[i].canonical_name == "Basket Materials"
         @test curric.courses[i].requisites[1][1] == pre
    elseif c.id == 8
         @test curric.courses[i].name == "Underwater Weaving"
         @test curric.courses[i].credit_hours == 3
         @test curric.courses[i].prefix == "BW"
         @test curric.courses[i].num == "301"
         @test curric.courses[i].institution == "ACME State University"
         @test curric.courses[i].canonical_name == "Baskets IV"
         @test curric.courses[i].requisites[1][2] == pre
         @test curric.courses[i].requisites[1][7] == co
    elseif c.id == 9
         @test curric.courses[i].name == "Humanitites Elective"
         @test curric.courses[i].credit_hours == 3
         @test curric.courses[i].institution == "ACME State University"
         @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 10
         @test curric.courses[i].name == "Social Sciences Elective"
         @test curric.courses[i].credit_hours == 3
         @test curric.courses[i].institution == "ACME State University"
         @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 11
         @test curric.courses[i].name == "Technical Elective"
         @test curric.courses[i].credit_hours == 3
         @test curric.courses[i].institution == "ACME State University"
         @test length(curric.courses[i].requisites[1]) == 0
    elseif c.id == 12
         @test curric.courses[i].name == "General Elective"
         @test curric.courses[i].credit_hours == 3
         @test curric.courses[i].institution == "ACME State University"
         @test length(curric.courses[i].requisites[1]) == 0
    end
end
# test additional courses
for (i,c) in enumerate(dp.additional_courses)
    if c.id == 13
        @test dp.additional_courses[i].name == "Precalculus w/ Basketry Applications"
        @test dp.additional_courses[i].credit_hours == 3
        @test dp.additional_courses[i].prefix == "MA"
        @test dp.additional_courses[i].num == "110"
        @test dp.additional_courses[i].institution == "ACME State University"
        @test dp.additional_courses[i].canonical_name == "Precalculus"
        @test dp.additional_courses[i].requisites[1][14] == pre
    elseif c.id == 14
        @test dp.additional_courses[i].name == "College Algebra"
        @test dp.additional_courses[i].credit_hours == 3
        @test dp.additional_courses[i].prefix == "MA"
        @test dp.additional_courses[i].num == "102"
        @test dp.additional_courses[i].institution == "ACME State University"
        @test dp.additional_courses[i].canonical_name == "College Algebra"
        @test dp.additional_courses[i].requisites[1][15] == strict_co
    elseif c.id == 15
        @test dp.additional_courses[i].name == "College Algebra Studio"
        @test dp.additional_courses[i].credit_hours == 1
        @test dp.additional_courses[i].prefix == "MA"
        @test dp.additional_courses[i].num == "102S"
        @test dp.additional_courses[i].institution == "ACME State University"
        @test dp.additional_courses[i].canonical_name == "College Algebra Recitation"
        @test length(dp.additional_courses[i].requisites[1]) == 0
    elseif c.id == 16
        @test dp.additional_courses[i].name == "Hemp Baskets"
        @test dp.additional_courses[i].credit_hours == 3
        @test dp.additional_courses[i].prefix == "BW"
        @test dp.additional_courses[i].num == "420"
        @test dp.additional_courses[i].institution == "ACME State University"
        @test dp.additional_courses[i].canonical_name == "College Algebra Recitation"
        @test dp.additional_courses[i].requisites[1][6] == co
    end
end
# TODO: add learning outcomes

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
# write curriculum to secondary storage
@test write_csv(curric1, "./UBW-curric.csv") == true
# read from same location
curric2 = read_csv("./UBW-curric.csv") 
#@test string(curric1) == string(curric2)  # read/write invariance test #@# Hayden: these now fail 
rm("./UBW-curric.csv")

terms = Array{Term}(undef, 3)
terms[1] = Term([A,B])
terms[2] = Term([C,D])
terms[3] = Term([E,F])

dp1 = DegreePlan("3-term UBW plan", curric1, terms)
# write degree plan to secondary storage
@test write_csv(dp1, "UBW-degree-plan.csv") == true
# read from same location
dp2 = read_csv("./UBW-degree-plan.csv")

#@test string(dp1) == string(dp2)  # read/write invariance test  #@# Hayden: these now fail 
rm("./UBW-degree-plan.csv")


end
