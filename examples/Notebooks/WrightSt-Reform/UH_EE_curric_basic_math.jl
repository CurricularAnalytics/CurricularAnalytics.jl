## Curriculum assoicated with the University of Houston EE program in 2018
## Note: curriculum was created in 2016-17 and was still used in 2018

# create the courses
c = Array{Course}(undef,52)

# pre-plan courses
c[50] = Course("Foundational Math", 3)
c[51] = Course("College Algebra", 3)
c[52] = Course("Trig. & Precalculus", 4)

# term 1
c[1] = Course("The US to 1877", 3, prefix = "HIST", num = "1377")
c[2] = Course("First Year Writing I", 3, prefix = "ENGL", num = "1303")
c[3] = Course("Intro to Engr.", 1, prefix = "ENGI", num = "1100")
c[4] = Course("Calculus I", 4, prefix = "MATH", num = "1431")
c[5] = Course("Fund. of Chemistry", 3, prefix = "CHEM", num = "1331")
c[6] = Course("Fund. of Chemistry Lab", 1, prefix = "CHEM", num = "1111")
# term 2
c[7] = Course("US Since 1877", 3, prefix = "HIST", num = "1378")
c[8] = Course("First Year Writing II", 3, prefix = "ENGL", num = "1304")
c[9] = Course("Computing & Prob. Solving", 3, prefix = "ENGI", num = "1331")
c[10] = Course("Calculus II", 4, prefix = "MATH", num = "1432")
c[11] = Course("University Physics I", 3, prefix = "PHYS", num = "1321")
c[12] = Course("Physics Lab I", 1, prefix = "PHYS", num = "1121")
# term 3
c[13] = Course("US and TX Constitutions & Politics", 3, prefix = "POLS", num = "1336")
c[14] = Course("Engineering Math", 3, prefix = "MATH", num = "3321")
c[15] = Course("Circuit Analysis I", 3, prefix = "ECE", num = "2201")
c[16] = Course("Calculus III", 3, prefix = "MATH", num = "2433")
c[17] = Course("University Physics II", 3, prefix = "PHYS", num = "1322")
c[18] = Course("Physics Lab II", 1, prefix = "PHYS", num = "1122")
# term 4
c[19] = Course("Technical Communication", 3, prefix = "ENGI", num = "2304")
c[20] = Course("Programming Apps in ECE", 3, prefix = "ECE", num = "3331")
c[21] = Course("Circuits Lab", 1, prefix = "ECE", num = "2100")
c[22] = Course("Circuit Analysis II", 3, prefix = "ECE", num = "2202")
c[23] = Course("Signals & Systems Analysis", 3, prefix = "ECE", num = "3337")
c[24] = Course("Microprocessors", 3, prefix = "ECE", num = "3436")
# term 5
c[25] = Course("Creative Arts Core", 3)
c[26] = Course("Electronics Lab", 1, prefix = "ECE", num = "3155")
c[27] = Course("Electronics", 3, prefix = "ECE", num = "3355")
c[28] = Course("Concentration Elective 1", 3)
c[29] = Course("Applied EM Waves", 3, prefix = "ECE", num = "3317")
c[30] = Course("ECE Elective 1", 3)
# term 6
c[31] = Course("US Gov: Congress, President and Courts", 3, prefix = "POLS", num = "1337")
c[32] = Course("Engineering Statistics", 3, prefix = "INDE", num = "2333")
c[33] = Course("Elective Lab 1", 1)
c[34] = Course("Concentration Elective 2", 3)
c[35] = Course("Numerical Methods", 3, prefix = "ECE", num = "3340")
c[36] = Course("ECE Elective 2", 3)
# term 7
c[37] = Course("Microeconomic Principles", 3, prefix = "ECON", num = "2304")
c[38] = Course("ECE Design I", 3, prefix = "ECE", num = "4335")
c[39] = Course("Elective Lab 2", 1)
c[40] = Course("Concentration Elective 3", 3)
c[41] = Course("Concentration Elective 4", 3)
c[42] = Course("Technical Elective", 3)
# term 8
c[43] = Course("Lang., Phil. & Culture Core", 3)
c[44] = Course("ECE Design II", 3, prefix = "ECE", num = "4336")
c[45] = Course("Elective Lab 3", 1)
c[46] = Course("Concentration Elective 5", 3)
c[47] = Course("Concentration Elective 6", 3)
c[48] = Course("Concentration Elective 7", 3)
c[49] = Course("Elective Lab 4", 1)

# pre-plan courses
add_requisite!(c[50],c[51],pre)
add_requisite!(c[51],c[52],pre)
add_requisite!(c[52],c[4],pre)

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

curric = Curriculum("University of Houston EE Program", c)

complexity(curric)

terms = Array{Term}(undef, 11)
terms[1] = Term([c[50]])
terms[2] = Term([c[51]])
terms[3] = Term([c[52]])
terms[4] = Term([c[1],c[2],c[3],c[4],c[5],c[6]])
terms[5] = Term([c[7],c[8],c[9],c[10],c[11],c[12]])
terms[6] = Term([c[13],c[14],c[15],c[16],c[17],c[18]])
terms[7] = Term([c[19],c[20],c[21],c[22],c[23],c[24]])
terms[8] = Term([c[25],c[26],c[27],c[28],c[29],c[30]])
terms[9] = Term([c[31],c[32],c[33],c[34],c[35],c[36]])
terms[10] = Term([c[37],c[38],c[39],c[40],c[41],c[42]])
terms[11] = Term([c[43],c[44],c[45],c[46],c[47],c[48],c[49]])

dp = DegreePlan("University of Houston EE Program 4-year Plan", curric, terms)