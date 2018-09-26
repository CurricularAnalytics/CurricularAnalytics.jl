## Curriculum assoicated with the Cornell University EE program in 2018

using CurricularAnalytics

# create the courses
c = Array{Course}(undef, 38)
# term 1
c[1] = Course("CHEM 2090", 3)
c[2] = Course("MATH 1910", 3)
c[3] = Course("ENGRI 1xxx", 3)
c[4] = Course("1st Yr Writing Seminar", 3)
c[5] = Course("PE", 3)
# term 2
c[6] = Course("PHYS 1112", 3)
c[7] = Course("MATH 1920", 3)
c[8] = Course("CS 111x", 3)
c[9] = Course("1st Yr Writing Seminar", 3)
c[10] = Course("PE", 3)
# term 3
c[11] = Course("PHYS 2213", 3)
c[12] = Course("MATH 2930", 3)
c[13] = Course("ECE/ENGRD 2100", 3)
c[14] = Course("MECE/ENGRD 2300", 3)
c[15] = Course("Liberal Studies", 3)
# term 4
c[16] = Course("PHYS 2214", 3)
c[17] = Course("MATH 2940", 3)
c[18] = Course("ENGRD 2xxx",31)
c[19] = Course("ECE 2200/ENGRD 2220", 3)
c[20] = Course("Liberal Studies", 3)
# term 5
c[21] = Course("ECE Foundations", 3)
c[22] = Course("Elective", 3)
c[23] = Course("Outside Tech. Elective", 3)
c[24] = Course("ECE 3400", 3)
c[25] = Course("Liberal Studies", 3)
# term 6
c[26] = Course("ECE Foundations", 3)
c[27] = Course("ECE Foundations", 3)
c[28] = Course("Outside Tech. Elective", 3)
c[29] = Course("Elective", 3)
c[30] = Course("Liberal Studies", 3)
# term 7
c[31] = Course("ECE Elective (CDE)", 3)
c[32] = Course("ECE Elective", 3)
c[33] = Course("Outside Tech. Elective", 3)
c[34] = Course("Liberal Studies", 3)
# term 8
c[35] = Course("ECE Elective", 3)
c[36] = Course("ECE Elective", 3)
c[37] = Course("ECE Elective", 3)
c[38] = Course("Liberal Studies", 3)

# term 1
add_requisite!(c[2],c[6],pre)
add_requisite!(c[2],c[7],pre)
# term 2
add_requisite!(c[6],c[11],pre)
add_requisite!(c[7],c[11],pre)
add_requisite!(c[7],c[12],pre)
add_requisite!(c[7],c[17],pre)
add_requisite!(c[8],c[14],pre)
add_requisite!(c[8],c[23],pre)
# term 3
add_requisite!(c[11],c[18],pre)
add_requisite!(c[11],c[13],co)
add_requisite!(c[12],c[16],co)
add_requisite!(c[12],c[13],co)
add_requisite!(c[12],c[19],pre)
add_requisite!(c[13],c[24],pre)
add_requisite!(c[14],c[24],pre)
# term 4
add_requisite!(c[17],c[19],co)
add_requisite!(c[19],c[24],pre)

curric = Curriculum("Cornell University EE Program", c)

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
terms[2] = Term([c[6],c[7],c[8],c[9],c[10]])
terms[3] = Term([c[11],c[12],c[13],c[14],c[15]])
terms[4] = Term([c[16],c[17],c[18],c[19],c[20]])
terms[5] = Term([c[21],c[22],c[23],c[24],c[25]])
terms[6] = Term([c[26],c[27],c[28],c[29],c[30]])
terms[7] = Term([c[31],c[32],c[33],c[34]])
terms[8] = Term([c[35],c[36],c[37],c[38]])

dp = DegreePlan("Cornell University EE Program 4-year Plan", curric, terms)

visualize(dp)