# Curric1: 4-vertex test curriculum - invalid (contains a cycle)
#
#    A *-------- C
#    |        */ |*
#    |*       /  |
#    B ------/   D
#
#

using CurricularAnalytics

a = Course("A", 3)
b = Course("B", 3)
c = Course("C", 3)
d = Course("D", 1)

add_requisite!(c,a,pre)
add_requisite!(b,c,pre)
add_requisite!(d,c,co)
add_requisite!(a,b,pre)

curric = Curriculum("Can't Finish", [a,b,c,d])

errors = IOBuffer()
if !isvalid_curriculum(curric, errors)
    println("Curriculum is not valid:")
    print(String(take!(errors)))
end
