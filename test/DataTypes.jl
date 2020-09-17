# DataTypes tests

using Dates
using LightGraphs

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
@test length(A.requisites) == 0
@test length(B.requisites) == 0
@test length(C.requisites) == 3
@test length(D.requisites) == 0
@test length(E.requisites) == 1
@test length(F.requisites) == 1

# Test delete_requisite! function
delete_requisite!(A,C);
@test length(C.requisites) == 2
add_requisite!(A,C,pre);

# Test Curriciulum creation 
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

# Test DegreePlan creation, other degree plan functions tested in ./test/DegreePlanAnalytics.jl
@test dp.name == "2019 Plan"
@test dp.curriculum === curric  # tests that they're the same object in memory
@test dp.num_terms == 4
@test dp.credit_hours == 22

# Test DegreeRequirements data types
@test grade("A➕") == grade(grade(convert(Grade,13)))
@test grade("A") == grade(grade(convert(Grade,12)))
@test grade("A➖") == grade(grade(convert(Grade,11)))
@test grade("B➕") == grade(grade(convert(Grade,10)))
@test grade("B") == grade(grade(convert(Grade,9)))
@test grade("B➖") == grade(grade(convert(Grade,8)))
@test grade("C➕") == grade(grade(convert(Grade,7)))
@test grade("C") == grade(grade(convert(Grade,6)))
@test grade("C➖") == grade(grade(convert(Grade,5)))
@test grade("D➕") == grade(grade(convert(Grade,4)))
@test grade("D") == grade(grade(convert(Grade,3)))
@test grade("D➖") == grade(grade(convert(Grade,2)))
@test grade("P") == 0
@test grade("F") == 0
@test grade("I") == 0
@test grade("WP") == 0
@test grade("W") == 0
@test grade("WF") == 0

# The regex's specified will match all courses with the EGR prefix and any number
cs1 = CourseSet("Test Course Set 1", 3, [(A=>grade("C")), (B=>grade("D"))], course_catalog=CCat, prefix_regex=r"^\s*+EGR\s*+$", num_regex=r".*", double_count=true);
@test cs1.name == "Test Course Set 1"
@test cs1.course_catalog == CCat
@test cs1.double_count == true
@test length(cs1.course_reqs) == 3
# The regex's specified will match all courses with number 111 and any prefix
cs2 = CourseSet("Test Course Set 2", 3, Array{Pair{Course,Grade},1}(), course_catalog=CCat, prefix_regex=r".*", num_regex=r"^\s*+111\s*+$");
@test cs2.double_count == false
@test length(cs2.course_reqs) == 1

req_set = AbstractRequirement[cs1,cs2];
rs = RequirementSet("Test Requirement Set", 6, req_set);
@test rs.name == "Test Requirement Set"
@test rs.credit_hours == 6
@test rs.satisfy == 2
rs = RequirementSet("Test Requirement Set", 6, req_set, satisfy=1);
@test rs.satisfy == 1
rs = RequirementSet("Test Requirement Set", 6, req_set, satisfy=5);
@test rs.satisfy == 2

# Test StudentRecord creation
cr1 = CourseRecord(A, grade("C"), "FALL 2020");
@test cr1.course == A
@test cr1.grade == 6
cr2 = CourseRecord(B, UInt64(13), "SPRING 2020");
@test cr2.grade == grade("A➕")
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

end;
