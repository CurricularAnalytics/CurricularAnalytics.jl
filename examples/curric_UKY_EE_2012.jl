## Curriculum assoicated with the University of Univ. of Kentucky EE program in 2012

using CurricularAnalytics

# create the courses
c = Array{Course}(undef,44)
# term 1
c[1] = Course("Creativity and Design in ECE", 3, prefix = "EE", num = "101")
c[2] = Course("Calculus I", 4, prefix = "MA", num = "113")
c[3] = Course("Intro. to Computer Programming", 3, prefix = "CS", num = "115")
c[4] = Course("Composition and Communication I", 3, prefix = "CIS/WRD", num = "110")
c[5] = Course("UK Core - Humanities", 3)
# term 2
c[6] = Course("Calculus II", 4, prefix = "MA", num = "114")
c[7] = Course("General University Physics", 4, prefix = "PHY", num = "231")
c[8] = Course("General University Physics Lab", 1, prefix = "PHY", num = "241")
c[9] = Course("General College Chemistry I", 4, prefix = "CHE", num = "105")
c[10] = Course("Design of Logic Circuits", 3, prefix = "EE", num = "280")
c[11] = Course("UK Core - Social Sciences", 3)
# term 3
c[12] = Course("Calculus III", 4, prefix = "MA", num = "213")
c[13] = Course("General University Physics", 4, prefix = "PHY", num = "232")
c[14] = Course("General University Physics Lab", 4, prefix = "PHY", num = "242")
c[15] = Course("Circuits I", 4, prefix = "EE", num = "211")
c[16] = Course("Composition and Communication II", 3, prefix = "CIS/WRD", num = "111")
# term 4
c[17] = Course("Calculus IV", 3, prefix = "MA", num = "214")
c[18] = Course("Circuits II", 3, prefix = "EE", num = "221")
c[19] = Course("Electrical Engineering Lab I", 2, prefix = "EE", num = "222")
c[20] = Course("Intro. to Semiconductor Devices", 3, prefix = "EE", num = "360")
c[21] = Course("Intro. to Program Design, Abstraction and Problem Solving", 4, prefix = "CS", num = "215")
c[22] = Course("UK Core - Citizenship-USA", 3)
# term 5
c[23] = Course("Electromechanics", 3, prefix = "EE", num = "415G")
c[24] = Course("Signals & Systems", 3, prefix = "EE", num = "421G")
c[25] = Course("Elective EE Laboratory", 2)
c[26] = Course("Microcomputer Organization", 3, prefix = "EE", num = "380")
c[27] = Course("Intro. to Electronics", 3, prefix = "EE", num = "461G")
c[28] = Course("Introductory Probability", 3, prefix = "MA", num = "320")
# term 6
c[29] = Course("Intro. to Engineering Electromagnetics", 4, prefix = "EE", num = "468G")
c[30] = Course("Elective EE Laboratory", 2)
c[31] = Course("Engineering/Science Elective", 3)
c[32] = Course("Technical Elective", 3)
c[33] = Course("UK Core – Statistical/Inferential Reasoning", 3)
# term 7
c[34] = Course("EE Capstone Design", 3, prefix = "EE", num = "490")
c[35] = Course("EE Technical Elective", 3)
c[36] = Course("EE Technical Elective", 3)
c[37] = Course("Elective EE Laboratory", 2)
c[38] = Course("Math/Statistics Elective", 3)
c[39] = Course("UK Core – Global Dynamics", 3)
# term 8
c[40] = Course("EE Capstone Design", 3, prefix = "EE", num = "491")
c[41] = Course("EE Technical Elective", 3)
c[42] = Course("EE Technical Elective", 3)
c[43] = Course("Supportive Elective", 3)
c[44] = Course("Engineering/Science Elective", 3)

# term 1
add_requisite!(c[2],c[8],pre)
add_requisite!(c[3],c[9],pre)
add_requisite!(c[4],c[3],co)
add_requisite!(c[4],c[9],pre)
add_requisite!(c[4],c[10],pre)
add_requisite!(c[5],c[6],co)
# term 2
add_requisite!(c[8],c[19],pre)
add_requisite!(c[9],c[32],pre)
add_requisite!(c[9],c[15],pre)
add_requisite!(c[10],c[14],pre)
add_requisite!(c[10],c[32],pre)
add_requisite!(c[10],c[16],pre)
add_requisite!(c[10],c[11],co)
add_requisite!(c[11],c[17],pre)
add_requisite!(c[11],c[12],co)
# term 3
add_requisite!(c[14],c[20],pre)
add_requisite!(c[14],c[15],co)
add_requisite!(c[15],c[19],pre)
add_requisite!(c[15],c[20],pre)
add_requisite!(c[15],c[22],pre)
add_requisite!(c[16],c[15],co)
add_requisite!(c[16],c[17],co)
add_requisite!(c[17],c[15],co)
add_requisite!(c[17],c[18],co)
add_requisite!(c[18],c[15],co)
add_requisite!(c[18],c[21],pre)
# term 4
add_requisite!(c[19],c[26],pre)
add_requisite!(c[20],c[35],pre)
add_requisite!(c[20],c[24],co)
add_requisite!(c[21],c[24],co)
add_requisite!(c[21],c[26],pre)
add_requisite!(c[22],c[21],co)
add_requisite!(c[22],c[23],co)
add_requisite!(c[23],c[27],pre)
add_requisite!(c[23],c[29],pre)
add_requisite!(c[24],c[38],pre)
# term 5
add_requisite!(c[26],c[38],pre)
add_requisite!(c[26],c[27],strict_co)
add_requisite!(c[27],c[38],pre)
add_requisite!(c[29],c[38],pre)
# term 6
add_requisite!(c[32],c[38],pre)
add_requisite!(c[35],c[38],pre)
# term 7
add_requisite!(c[37],c[38],co)
add_requisite!(c[38],c[44],pre)

curric = Curriculum("University of Kentucky EE Program", c)

errors = IOBuffer()
if isvalid_curriculum(curric, errors)
    println("Curriculum $(curric.name) is valid")
    println("  delay factor = $(delay_factor(curric))")
    println("  blocking factor = $(blocking_factor(curric))")
    println("  centrality factor = $(centrality(curric))")
    println("  curricular complexity = $(complexity(curric))")
else
    println("Curriculum $(curric.name) is not valid:")
    print(String(take!(errors)))
end

terms = Array{Term}(undef, 8)
terms[1] = Term([c[1],c[2],c[3],c[4],c[5]])
terms[2] = Term([c[6],c[7],c[8],c[9],c[10],c[11]])
terms[3] = Term([c[12],c[13],c[14],c[15],c[16]])
terms[4] = Term([c[17],c[18],c[19],c[20],c[21],c[22]])
terms[5] = Term([c[23],c[24],c[25],c[26],c[27],c[28]])
terms[6] = Term([c[29],c[30],c[31],c[32],c[33]])
terms[7] = Term([c[34],c[35],c[36],c[37],c[38],c[39]])
terms[8] = Term([c[40],c[41],c[42],c[43],c[44]])

dp = DegreePlan("University of Kentucky EE Program 4-year Plan", curric, terms)

visualize(dp)
