A = Course("Introduction to Baskets", 3, institution="ACME State University", prefix="BW", num="110", canonical_name="Baskets I");
B = Course("Swimming", 3, institution="ACME State University", prefix="PE", num="115", canonical_name="Physical Education");
C = Course("Basic Basket Forms", 3, institution="ACME State University", prefix="BW", num="111", canonical_name="Baskets I");
D = Course("Basic Basket Forms Lab", 1, institution="ACME State University", prefix="BW", num="111L", canonical_name="Baskets I Laboratory");
E = Course("Advanced Basketry", 3, institution="ACME State University", prefix="BW", num="300", canonical_name="Baskets II");
F = Course("Basket Materials & Decoration", 3, institution="ACME State University", prefix="BW", num="214", canonical_name="Basket Materials");
G = Course("Humanitites Elective", 3, institution="ACME State University", prefix="EGR", num="101", canonical_name="Humanitites Core");
H = Course("Technical Elective", 3, institution="ACME State University", prefix="BW", num="3xx", canonical_name="Elective");

add_requisite!(C,E,pre);
add_requisite!(D,F,pre);
reqs = Array{AbstractCourse,1}();
push!(reqs, A,B,D);
add_requisite!(reqs,C,[pre,pre,co]);

curric = Curriculum("Underwater Basket Weaving", [A,B,C,D,E,F,G,H], institution="ACME State University", CIP="445786");

terms = Array{Term}(undef, 4);
terms[1] = Term([A,B]);
terms[2] = Term([C,D]);
terms[3] = Term([E,F]);
terms[4] = Term([G,H]);

dp = DegreePlan("2019 Plan", curric, terms);



