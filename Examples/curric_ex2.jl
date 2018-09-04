# Curric1: 6-vertex test curriculum - valid
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
# Block factor for A = 5
# Delay factor of A = 4

include("CurricularAnalytics.jl")

a = Course("A", 3)
b = Course("B", 1)
c = Course("C", 3)
d = Course("D", 1)
e = Course("E", 3)
f = Course("F", 3)
g = Course("G", 3)

add_requisite!(a,b,co)
add_requisite!(a,c,pre)
add_requisite!(b,d,pre)
add_requisite!(c,d,co)
add_requisite!(c,e,pre)
add_requisite!(d,f,pre)
add_requisite!(d,g,co)
add_requisite!(g,f,pre)

curric = Curriculum("Postmodern Basket Weaving", [a,b,c,d,e,f,g])

complexity(curric)
centrality(curric)
println("Analytics for $(curric.name):")
println("  blocking factor = $(curric.metrics["blocking factor"])")
println("  delay factor = $(curric.metrics["delay factor"])")
println("  curricular centrality = $(curric.metrics["centrality"])")
println("  curricular complexity = $(curric.metrics["complexity"])")
