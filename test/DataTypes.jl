# DataTypes tests

using Dates
using Graphs

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

include("test_degree_plan.jl")

# Test Course creation 
@test A.name == "Introduction to Baskets"
@test A.credit_hours == 3
@test A.prefix == "BW"
@test A.num == "110"
@test A.institution == "ACME State University"
@test A.canonical_name == "Baskets I"

# Test course_id function 
@test course_id(A.prefix, A.num, A.name, A.institution) == convert(Int, mod(hash(A.name * A.prefix * A.num * A.institution), UInt32))

# Test add_requisite! function
@test length(A.requisites[1]) == 0
@test length(B.requisites[1]) == 0
@test length(C.requisites[1]) == 3
@test length(D.requisites[1]) == 0
@test length(E.requisites[1]) == 1
@test length(F.requisites[1]) == 1

# Test delete_requisite! function
delete_requisite!(A,C);
@test length(C.requisites[1]) == 2
add_requisite!(A,C,pre);

# Test Curriciulum creation 
@test curric.name == "Underwater Basket Weaving"
@test curric.institution == "ACME State University"
@test curric.degree_type == "BS"
@test curric.system_type == semester
@test curric.CIP == "445786"
@test curric.num_courses == 8
@test curric.credit_hours == 22

# test the underlying graph
@test nv(curric.graph) == 8
@test ne(curric.graph) == 5

lo1 = LearningOutcome("Test learning outcome #1", "students will demonstrate ability to do #1", 12)
lo2 = LearningOutcome("Test learning outcome #1", "students will demonstrate ability to do #2", 10)
lo3 = LearningOutcome("Test learning outcome #1", "students will demonstrate ability to do #3", 15)
lo4 = LearningOutcome("Test learning outcome #1", "students will demonstrate ability to do #3", 7)
add_lo_requisite!(lo1, lo2, pre)
add_lo_requisite!([lo2, lo3], lo4, [pre, co])
@test length(lo1.requisites) == 0
@test length(lo2.requisites) == 1
@test length(lo3.requisites) == 0
@test length(lo4.requisites) == 2

# test the uderlying learning outcome graph
#@test nv(curric.graph) == 8
#@test ne(curric.graph) == 5

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
@test course(curric, "BW", "110", "Introduction to Baskets", "ACME State University") == A
id = A.id
convert_ids(curric); # this should not change the ids, since the curriculum was not created from a CSV file
@test A.id == id
test_curric = read_csv("./curriculum.csv")
convert_ids(test_curric);  # this should change the ids
@test course(test_curric, "BW", "110", "Introduction to Baskets", "ACME State University").id == convert(Int, mod(hash("Introduction to Baskets" * "BW" * "110" * "ACME State University"), UInt32))

# Test CourseCollection creation 
CC = CourseCollection("Test Course Collection", 3, [A,B,C,E], institution="ACME State University");
@test CC.name == "Test Course Collection"
@test CC.credit_hours == 3
@test length(CC.courses) == 4
@test CC.institution == "ACME State University"

# Test CourseCatalog creation 
CCat = CourseCatalog("Test Course Catalog", "ACME State University", courses=[A], catalog=Dict([(B.id=>B),C.id=>C]), date_range=(Date(2019,8), Date(2020,7,31)));
@test CCat.name == "Test Course Catalog"
@test CCat.institution == "ACME State University"
@test length(CCat.catalog) == 3

# Test add_course! functions
add_course!(CCat, [D]);
@test length(CCat.catalog) == 4
add_course!(CCat, [E,F,G]);
@test length(CCat.catalog) == 7
@test is_duplicate(CCat, A) == true
@test is_duplicate(CCat, H) == false
@test (CCat.date_range[2] - CCat.date_range[1]) == Dates.Day(365)
@test A == course(CCat, "BW", "110", "Introduction to Baskets")

# Test remove_course! functions
remove_course!(CCat, E);
@test length(CCat.catalog) == 6
remove_course!(CCat, [F,G]);
@test length(CCat.catalog) == 4

# add the courses back for later testing
add_course!(CCat, [E,F,G]);

# Test DegreePlan creation, other degree plan functions tested in ./test/DegreePlanAnalytics.jl
@test dp.name == "2019 Plan"
@test dp.curriculum === curric  # tests that they're the same object in memory
@test dp.num_terms == 4
@test dp.credit_hours == 22

# Test Grade and GradingSystem data types
@test @isdefined(Grade)
@test @isdefined(GradingSystem)
grades = Set{Grade}([
    Grade("A➕", UInt64(13), 13/3.0),
    Grade("A",  UInt64(12), 12/3.0),
    Grade("A➖", UInt64(11), 11/3.0),
    Grade("B➕", UInt64(10), 10/3.0),
    Grade("B",  UInt64(9),  9/3.0),
    Grade("B➖", UInt64(8),  8/3.0),
    Grade("C➕", UInt64(7),  7/3.0),
    Grade("C",  UInt64(6),  6/3.0),
    Grade("C➖", UInt64(5),  5/3.0),
    Grade("D➕", UInt64(4),  4/3.0),
    Grade("D",  UInt64(3),  3/3.0),
    Grade("D➖", UInt64(2),  2/3.0),

    Grade("P",  UInt64(0), 0/3.0),
    Grade("F",  UInt64(0), 0/3.0),
    Grade("I",  UInt64(0), 0/3.0),
    Grade("WP", UInt64(0), 0/3.0),
    Grade("W",  UInt64(0), 0/3.0),
    Grade("WF", UInt64(0), 0/3.0),
])
gradingSystem = GradingSystem(grades)

expected = Dict(
        "A➕" => (UInt64(13), 13/3.0),
        "A"  => (UInt64(12), 12/3.0),
        "A➖" => (UInt64(11), 11/3.0),
        "B➕" => (UInt64(10), 10/3.0),
        "B"  => (UInt64(9),  9/3.0),
        "B➖" => (UInt64(8),  8/3.0),
        "C➕" => (UInt64(7),  7/3.0),
        "C"  => (UInt64(6),  6/3.0),
        "C➖" => (UInt64(5),  5/3.0),
        "D➕" => (UInt64(4),  4/3.0),
        "D"  => (UInt64(3),  3/3.0),
        "D➖" => (UInt64(2),  2/3.0),

        "P"  => (UInt64(0), 0.0),
        "F"  => (UInt64(0), 0.0),
        "I"  => (UInt64(0), 0.0),
        "WP" => (UInt64(0), 0.0),
        "W"  => (UInt64(0), 0.0),
        "WF" => (UInt64(0), 0.0),
    )

@test length(gradingSystem.grades) == length(expected)
for g in gradingSystem.grades
    @test haskey(expected, g.symbol)

    exp_value, exp_credits = expected[g.symbol]
    @test g.value  == exp_value
    @test g.credits == exp_credits
end

# Test is_valid() on DegreeRequirements


# The regex's specified will match all courses with the EGR prefix and any number
cs1 = CourseSet("Test Course Set 1", 3, Grade("D",  UInt64(3),  3/3.0),[(A=>Grade("C",  UInt64(6),  6/3.0)), (B=>Grade("D",  UInt64(3),  3/3.0))],course_catalog=CCat, prefix_regex=r"^\s*+EGR\s*+$", num_regex=r".*", double_count=true);
@test cs1.name == "Test Course Set 1"
@test cs1.course_catalog == CCat
@test length(cs1.course_reqs) == 3
# The regex's specified will match all courses with number 111 and any prefix
cs2 = CourseSet("Test Course Set 2", 3, Grade("D",  UInt64(3),  3/3.0), Array{Pair{Course,Grade},1}(), course_catalog=CCat, prefix_regex=r".*", num_regex=r"^\s*+111\s*+$");
@test length(cs2.course_reqs) == 1

req_set = AbstractRequirement[cs1,cs2];
rs = RequirementSet("Test Requirement Set", 6, req_set);
@test rs.name == "Test Requirement Set"
@test rs.credit_hours == 6
@test rs.satisfy == 2
rs = RequirementSet("Test Requirement Set", 6, req_set, satisfy=1);
@test rs.satisfy == 1
rs = RequirementSet("Test Requirement Set", 6, req_set, satisfy=2);
@test rs.satisfy == 2

# Test StudentRecord creation
cr1 = CourseRecord(A, Grade("C",  UInt64(6),  6/3.0), "FALL 2020");
@test cr1.course == A
@test cr1.grade.value == 6
cr2 = CourseRecord(B, Grade("A➕", UInt64(13), 13/3.0), "SPRING 2020");
@test cr2.grade.symbol == "A➕"
std_rec = StudentRecord("A14356", "Patti", "Furniture", "O", [cr1, cr2]);
@test length(std_rec.transcript) == 2

# Test Student creation
std = Student(1, attributes = Dict("race" => "other", "HS_GPA" => 3.5));
@test length(std.attributes) == 2
stds = simple_students(100);
@test length(stds) == 100 

# Test TransferArticulation creation
XA = Course("Baskets 101", 3, institution="Tri-county Community College", prefix="BW", num="101", canonical_name="Baskets I");
XB = Course("Fun w/ Baskets", 3, institution="South Harmon Institute of Technology", prefix="FUN", num="101", canonical_name="Baskets I");
XCat1 = CourseCatalog("Another Course Catalog", "Tri-county Community College", courses=[XA], date_range=(Date(2019,8), Date(2020,7,31)));
XCat2 = CourseCatalog("Yet Another Course Catalog", "South Harmon Institute of Technology", courses=[XB], date_range=(Date(2019,8), Date(2020,7,31)));
#xfer_map = Dict((XCat.id, XA.id) => [A.id])  # this should work, but it fails
#ta = TransferArticulation("Test Xfer Articulation", "ACME State University", CCat, Dict(XCat.id => XCat), xfer_map);
ta = TransferArticulation("Test Xfer Articulation", "ACME State University", CCat, Dict(XCat1.id => XCat1));
add_transfer_catalog(ta, XCat2);
@test length(ta.transfer_catalogs) == 2
add_transfer_course(ta, [A.id], XCat1.id, XA.id)
add_transfer_course(ta, [A.id], XCat2.id, XB.id)
@test transfer_equiv(ta, XCat1.id, XA.id) == [A.id]
@test transfer_equiv(ta, XCat2.id, XB.id) == [A.id]

# Test Simulation creation 
sim_obj = Simulation(dp);
@test sim_obj.degree_plan == dp

# ------------------------------------------------------------
# no_multi_use cannot contain itself
# Intent: a CourseSet must never be mutually-exclusive with itself
# (self-exclusion is meaningless and can create confusing constraints later).
# ------------------------------------------------------------
 @testset "no_multi_use cannot contain itself" begin
     C1 = Course("CourseA", 3)

     # Attempt to incorrectly include cs1 in its own no_multi_use set
     cs1 = CourseSet(
         "cs1",
         3,
         Grade("D",  UInt64(3),  3/3.0),
         [C1 => Grade("D",  UInt64(3),  3/3.0)],
         description="",
         no_multi_use=Set{CourseSet}()  # start empty; we'll add a course set later
     )

     # User mistake: trying to add course set to its own no_multi_use set
     add_no_multi_use!(cs1, Set([cs1]))

     # "Proof" expectation: implementation should prevent this (by auto-removing).
     @test !(cs1 ∈ cs1.no_multi_use)  # must be false if the rule is enforced
 end

# ------------------------------------------------------------
# add_no_multi_use! testing 
# add course sets to the no_multi_use set.
# ------------------------------------------------------------
 @testset "add_no_multi_use! and remove_no_multi_use!" begin
     C1 = Course("CourseA", 3)

     # create two course set
     cs1 = CourseSet(
         "cs1",
         3,
         Grade("D",  UInt64(3),  3/3.0),
         [C1 => Grade("D",  UInt64(3),  3/3.0)],
     )

    cs2 = CourseSet(
         "cs2",
         3,
         Grade("D",  UInt64(3),  3/3.0),
         [C1 => Grade("D",  UInt64(3),  3/3.0)],
     )

     # add a course set
     add_no_multi_use!(cs1, Set([cs2]))
     @test cs2 ∈ cs1.no_multi_use  

    # now remove it
    remove_no_multi_use!(cs1, Set([cs2]))
    @test !(cs2 ∈ cs1.no_multi_use)  
 end
 
end
