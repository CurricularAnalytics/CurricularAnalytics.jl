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

a = Course("Calculus 1", 3, "MA", "113")
b = Course("Programming Into", 3, "CS", "115")
c = Course("Digital Logic", 3, "CS", "270")
d = Course("Calculus 2", 1, "MA", "114")
e = Course("C++ Programming", 3, "CS", "300")
f = Course("Data Systems", 3, "CS", "214")
g = Course("Intro to Engineering", 3, "EGR", "101")
h = Course("Physics 1", 3, "PHY", "231")

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

print_plan(dp)

visualize(dp, changed = function (new_data)
  println(new_data)
end)
