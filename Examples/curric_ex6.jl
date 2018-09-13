# Curric1: 4-vertex test curriculum - invalid (contains a extraneous prerequisite)
#
#    A --------* C
#    |        */ |*
#    |*       /  |
#    B ------/   D
#
#

include("CurricularAnalytics.jl")

a = Course("A", 3)
b = Course("B", 3)
c = Course("C", 3)
d = Course("D", 1)

add_requisite!(a,c,pre)
add_requisite!(b,c,pre)
add_requisite!(d,c,co)
add_requisite!(a,b,pre)

curric = Curriculum("Extraneous", [a,b,c,d])

errors = IOBuffer()
if !isvalid_curriculum(curric, errors)
    println("Curriculum is not valid:")
    print(String(take!(errors)))
end
