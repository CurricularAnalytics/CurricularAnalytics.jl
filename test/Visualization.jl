# homology tests
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

c1 = Curriculum("C1", [A,B,C,D,G,H], institution="ACME State University", CIP="445786",sortby_ID=false)
c2 = Curriculum("C2", [A,B,C,D,E,F,G], institution="ACME State University", CIP="445786",sortby_ID=false)
sim = homology([c1,c2])
@test sim[1,1] == 1.0
@test sim[1,2] ≈ 0.71428 atol=0.001
@test sim[2,1] ≈ 0.83333 atol=0.001
@test sim[2,2] == 1.0