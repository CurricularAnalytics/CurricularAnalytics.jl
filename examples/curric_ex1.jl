# Curric1: 8-vertex test curriculum - valid
#
#    A --------* C --------* E           G
#             */ |*
#             /  |
#    B-------/   D --------* F           H
#
#    (A,C) - pre;  (C,E) -  pre; (B,C) - pre; (D,C) - co; (C,E) - pre; (D,F) - pre
#
#

using CurricularAnalytics

a = Course("Calculus 1", 3, prefix="MA", num="113")
b = Course("Programming Into", 3, prefix="CS", num="115")
c = Course("Digital Logic", 3, prefix="CS", num="270")
d = Course("Calculus 2", 1, prefix="MA", num="114")
e = Course("C++ Programming", 3, prefix="CS", num="300")
f = Course("Data Systems", 3, prefix="CS", num="214")
g = Course("Intro to Engineering", 3, prefix="EGR", num="101")
h = Course("Physics 1", 3, prefix="PHY", num="231", canonical_name="Classical Mechanics")

add_requisite!(a,c,pre)
add_requisite!(b,c,pre)
add_requisite!(d,c,co)
add_requisite!(c,e,pre)
add_requisite!(d,f,pre)

curric = Curriculum("Underwater Basket Weaving", [a,b,c,d,e,f,g,h])

complexity(curric)
centrality(curric)
println("Analytics for $(curric.name):")
println("  blocking factor = $(curric.metrics["blocking factor"])")
println("  delay factor = $(curric.metrics["delay factor"])")
println("  curricular centrality = $(curric.metrics["centrality"])")
println("  curricular complexity = $(curric.metrics["complexity"])")

terms = Array{Term}(undef, 4)
terms[1] = Term([a,b])
terms[2] = Term([c,d])
terms[3] = Term([e,f])
terms[4] = Term([g,h])

dp = DegreePlan("MyPlan", curric, terms)

# println(dp)

print_plan(dp)

visualize(dp)
