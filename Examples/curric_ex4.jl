# Curric: 6-vertex test curriculum - valid
#
#    A --------* C --------* E
#    |           |
#    |*          |*
#    B---------* D --------* F
#      #
#    (A,B) - co; (A,C) - pre; (B,D) - pre; (C,D) -  co;
#    (C,E) - pre; (D,F) - pre
#
# centrality B = 4
# centrality C = 7
# centrality D = 8

using CurricularAnalytics

a = Course("A", 3)
b = Course("B", 1)
c = Course("C", 3)
d = Course("D", 1)
e = Course("E", 3)
f = Course("F", 3)

add_requisite!(a,b,co)
add_requisite!(a,c,pre)
add_requisite!(b,d,pre)
add_requisite!(c,d,co)
add_requisite!(c,e,pre)
add_requisite!(d,f,pre)

curric1 = Curriculum("Postmodern Basket Weaving", [a,b,c,d,e,f])
println("Analytics for $(curric1.name):")
println(" Centrality of course $(curric1.courses[2].name) = $(centrality(curric1,2))")
println(" Centrality of course $(curric1.courses[3].name) = $(centrality(curric1,3))")
println(" Centrality of course $(curric1.courses[4].name) = $(centrality(curric1,4))")

# Add vertex G with two additional edges
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
# centrality B = 9
# centrality C = 12
# centrality D = 18
# centrality G = 10

g = Course("G", 3)

add_requisite!(d,g,co)
add_requisite!(g,f,pre)

curric2 = Curriculum("Postmodern Basket Weaving - Revised", [a,b,c,d,e,f,g])
println("Analytics for $(curric2.name):")
println(" Centrality of course $(curric1.courses[2].name) = $(centrality(curric1,2))")
println(" Centrality of course $(curric2.courses[3].name) = $(centrality(curric2,3))")
println(" Centrality of course $(curric2.courses[4].name) = $(centrality(curric2,4))")
println(" Centrality of course $(curric2.courses[7].name) = $(centrality(curric2,7))")
