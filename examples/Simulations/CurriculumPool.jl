function Example_C1()
    # create the courses
    c = Array{Course}(undef, 4)

    # term 1
    c[1] = Course("Calculus 1", 3, prefix = "MATH ", num = "1011")

    # term 2
    c[2] = Course("Physics I: Mechanics & Heat", 3, prefix = "PHYS", num = "1112")
    c[3] = Course("Calculus 2", 3, prefix = "MATH", num = "1920")
    #test1
    # term 3
    c[4] = Course("Circuits 1", 3, prefix = "EE", num = "2200")

    # term 1
    add_requisite!(c[1],c[2],pre)
    add_requisite!(c[1],c[3],pre)

    # term 2
    add_requisite!(c[2],c[4],pre)

    curric = Curriculum("Example Curricula c1", c)

    errors = IOBuffer()
    if is_valid(curric, errors)
        println("Curriculum $(curric.name) is valid")
        println("  delay factor = $(delay_factor(curric))")
        println("  blocking factor = $(blocking_factor(curric))")
        println("  centrality factor = $(centrality(curric))")
        println("  curricular complexity = $(complexity(curric))")

        terms = Array{Term}(undef, 3)
        terms[1] = Term([c[1]])
        terms[2] = Term([c[2],c[3]])
        terms[3] = Term([c[4]])

        dp = DegreePlan("Example Curricula c1", curric, terms)

        take!(errors) # clear the IO buffer
        if is_valid(dp, errors)
            println("Degree plan $(dp.name) is valid")
            return c, dp
        else
            println("Degree plan $(dp.name) is not valid:")
            print(String(take!(errors)))
            println("\nDiplaying degree plan for debugging purposes...")
        end
    else
        println("Curriculum $(curric.name) is not valid:")
        print(String(take!(errors)))
    end
end

function Example_C2()
    # create the courses
    c = Array{Course}(undef, 4)

    # term 1
    c[1] = Course("Calculus 1", 3, prefix = "MATH ", num = "1011")
    c[2] = Course("Physics I: Mechanics & Heat", 3, prefix = "PHYS", num = "1112")

    # term 2
    c[3] = Course("Calculus 2", 3, prefix = "MATH", num = "1920")

    # term 3
    c[4] = Course("Circuits 1", 3, prefix = "EE", num = "2200")
    # test
    # term 2
    add_requisite!(c[1],c[3],pre)
    add_requisite!(c[2],c[3],pre)

    # term 3
    add_requisite!(c[3],c[4],pre)

    curric = Curriculum("Example Curricula C2", c)

    errors = IOBuffer()
    if is_valid(curric, errors)
        println("Curriculum $(curric.name) is valid")
        println("  delay factor = $(delay_factor(curric))")
        println("  blocking factor = $(blocking_factor(curric))")
        println("  centrality factor = $(centrality(curric))")
        println("  curricular complexity = $(complexity(curric))")

        terms = Array{Term}(undef, 3)
        terms[1] = Term([c[1],c[2]])
        terms[2] = Term([c[3]])
        terms[3] = Term([c[4]])

        dp = DegreePlan("Example Curricula c2", curric, terms)

        take!(errors) # clear the IO buffer
        if is_valid(dp, errors)
            println("Degree plan $(dp.name) is valid")
            return c, dp
        else
            println("Degree plan $(dp.name) is not valid:")
            print(String(take!(errors)))
            println("\nDiplaying degree plan for debugging purposes...")
        end
    else
        println("Curriculum $(curric.name) is not valid:")
        print(String(take!(errors)))
    end
end

function UH_EE_curric()
    # create the courses
    c = Array{Course}(undef,49)
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
    c[28] = Course("Concentration Elective", 3)
    c[29] = Course("Applied EM Waves", 3, prefix = "ECE", num = "3317")
    c[30] = Course("ECE Elective", 3)
    # term 6
    c[31] = Course("US Gov: Congress, President and Courts", 3, prefix = "POLS", num = "1337")
    c[32] = Course("Engineering Statistics", 3, prefix = "INDE", num = "2333")
    c[33] = Course("Elective Lab", 1)
    c[34] = Course("Concentration Elective", 3)
    c[35] = Course("Numerical Methods", 3, prefix = "ECE", num = "3340")
    c[36] = Course("ECE Elective", 3)
    # term 7
    c[37] = Course("Microeconomic Principles", 3, prefix = "ECON", num = "2304")
    c[38] = Course("ECE Design I", 3, prefix = "ECE", num = "4335")
    c[39] = Course("Elective Lab", 1)
    c[40] = Course("Concentration Elective", 3)
    c[41] = Course("Concentration Elective", 3)
    c[42] = Course("Tecnical Elective", 3)
    # term 8
    c[43] = Course("Lang., Phil. & Culture Core", 3)
    c[44] = Course("ECE Design II", 3, prefix = "ECE", num = "4336")
    c[45] = Course("Elective Lab", 1)
    c[46] = Course("Concentration Elective", 3)
    c[47] = Course("Concentration Elective", 3)
    c[48] = Course("Concentration Elective", 3)
    c[49] = Course("Elective Lab", 1)

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

    errors = IOBuffer()
    if is_valid(curric, errors)
        println("Curriculum $(curric.name) is valid")
        println("  delay factor = $(delay_factor(curric))")
        println("  blocking factor = $(blocking_factor(curric))")
        println("  centrality factor = $(centrality(curric))")
        println("  curricular complexity = $(complexity(curric))")

        terms = Array{Term}(undef, 8)
        terms[1] = Term([c[1],c[2],c[3],c[4],c[5],c[6]])
        terms[2] = Term([c[7],c[8],c[9],c[10],c[11],c[12]])
        terms[3] = Term([c[13],c[14],c[15],c[16],c[17],c[18]])
        terms[4] = Term([c[19],c[20],c[21],c[22],c[23],c[24]])
        terms[5] = Term([c[25],c[26],c[27],c[28],c[29],c[30]])
        terms[6] = Term([c[31],c[32],c[33],c[34],c[35],c[36]])
        terms[7] = Term([c[37],c[38],c[39],c[40],c[41],c[42]])
        terms[8] = Term([c[43],c[44],c[45],c[46],c[47],c[48],c[49]])

        dp = DegreePlan("University of Houston EE Program 4-year Plan", curric, terms)

        take!(errors) # clear the IO buffer
        if is_valid(dp, errors)
            println("Degree plan $(dp.name) is valid")
            return c, dp
        else
            println("Degree plan $(dp.name) is not valid:")
            print(String(take!(errors)))
            println("\nDiplaying degree plan for debugging purposes...")
        end

        # basic_metrics(dp)
        # dp.metrics

    else # invalid curriculum
        println("Curriculum $(curric.name) is not valid:")
        print(String(take!(errors)))
    end
end

function UKY_EE_curric()
    # create the courses
    c = Array{Course}(undef,43)
    # term 1
    c[1] = Course("Engineering Exploration I", 1, prefix = "EGR", num = "101")
    c[2] = Course("Fundamentals of Engineering Computing", 2, prefix = "EGR", num = "102")
    c[3] = Course("General University Physics", 4, prefix = "PHY", num = "231")
    c[4] = Course("General University Physics Lab", 1, prefix = "PHY", num = "241")
    c[5] = Course("Composition and Communication I", 3, prefix = "CIS/WRD", num = "110")
    c[6] = Course("Calculus I", 4, prefix = "MA", num = "113")

    # term 2
    c[7] = Course("Engineering Exploration II", 2, prefix = "EGR", num = "103")
    c[8] = Course("Composition and Communication II", 3, prefix = "CIS/WRD", num = "111")
    c[9] = Course("Calculus II", 4, prefix = "MA", num = "114")
    c[10] = Course("General College Chemistry I", 4, prefix = "CHE", num = "105")
    c[11] = Course("UK Core - Social Sciences", 3)

    # term 3
    c[12] = Course("Calculus III", 4, prefix = "MA", num = "213")
    c[13] = Course("General University Physics", 4, prefix = "PHY", num = "232")
    c[14] = Course("General University Physics Lab", 1, prefix = "PHY", num = "242")
    c[15] = Course("Circuits I", 4, prefix = "EE", num = "211")
    c[16] = Course("Digital Logic Design", 4, prefix = "EE", num = "282")

    # term 4
    c[17] = Course("Calculus IV", 3, prefix = "MA", num = "214")
    c[18] = Course("AC Circuits", 4, prefix = "EE", num = "223")
    c[19] = Course("Intro. to Embedded Systems", 4, prefix = "EE", num = "287")
    c[20] = Course("Intro. to Program Design Abstraction and Problem Solving", 4, prefix = "CS", num = "215")
    c[21] = Course("UK Core - Humanities", 3)

    # term 5
    c[22] = Course("Electromechanics", 3, prefix = "EE", num = "415G")
    c[23] = Course("Signals & Systems", 3, prefix = "EE", num = "421G")
    c[24] = Course("Elective EE Laboratory 1", 2)
    c[25] = Course("Intro. to Electronics", 3, prefix = "EE", num = "461G")
    c[26] = Course("Introductory Probability", 3, prefix = "MA", num = "320")
    c[27] = Course("Technical Elective 1", 3)

    # term 6
    c[28] = Course("Intro. to Engineering Electromagnetics", 4, prefix = "EE", num = "468G")
    c[29] = Course("Elective EE Laboratory 2", 2)
    c[30] = Course("Engineering/Science Elective 1", 3)
    c[31] = Course("Technical Elective 2", 3)
    c[32] = Course("UK Core - Citizenship - USA", 3)

    # term 7
    c[33] = Course("EE Capstone Design", 3, prefix = "EE", num = "490")
    c[34] = Course("EE Technical Elective 1", 3)
    c[35] = Course("EE Technical Elective 2", 3)
    c[36] = Course("Math/Statistics Elective", 3)
    c[37] = Course("UK Core - Global Dynamics", 3)

    # term 8
    c[38] = Course("EE Capstone Design", 3, prefix = "EE", num = "491")
    c[39] = Course("EE Technical Elective 3", 3)
    c[40] = Course("EE Technical Elective 4", 3)
    c[41] = Course("Supportive Elective", 3)
    c[42] = Course("Engineering/Science Elective 2", 3)
    c[43] = Course("UK Core - Statistical Inferential Reasoning", 3)

    # term 1
        add_requisite!(c[2],c[7],pre)
        add_requisite!(c[2],c[16],pre)
        # add_requisite!(c[2],c[6],co)  # not correct
        # add_requisite!(c[2],c[20],pre)  # redundant
        # add_requisite!(c[2],c[3],co)  # not correct
        add_requisite!(c[3],c[7],co)    # added
        add_requisite!(c[3],c[13],pre)
        add_requisite!(c[3],c[4],co)  # was wrong direction, flipped
        add_requisite!(c[5],c[8],pre)
        add_requisite!(c[6],c[3],co)  # was wrong direction, flipped
        add_requisite!(c[6],c[7],co)  # added, a required edge being removed by viz
        add_requisite!(c[6],c[9],pre)

    # term 2
        add_requisite!(c[9],c[12],pre)
        # add_requisite!(c[9],c[15],pre)  # redundant
        add_requisite!(c[10],c[7],co)   # added

    # term 3
        # add_requisite!(c[3],c[13],pre)  # already specified above
        add_requisite!(c[12],c[13],co)
        add_requisite!(c[12],c[17],pre)
        add_requisite!(c[12],c[26],pre)
        add_requisite!(c[12],c[28],pre)  # required edge correctly removed by viz, but not caught by isvalid_curric()
        add_requisite!(c[13],c[14],co)
        add_requisite!(c[13],c[15],co)
        add_requisite!(c[13],c[22],pre)  # required edge being removed by viz
        add_requisite!(c[14],c[15],co)
        # add_requisite!(c[14],c[18],pre)  # not correct
        add_requisite!(c[15],c[18],pre)  # added
        add_requisite!(c[16],c[19],pre)

    # term 4
        add_requisite!(c[17],c[18],co)
        add_requisite!(c[17],c[23],pre)  # required edge being removed by viz
        add_requisite!(c[18],c[22],pre)
        add_requisite!(c[18],c[23],pre)
        add_requisite!(c[18],c[25],pre)
        add_requisite!(c[18],c[28],pre)
        add_requisite!(c[20],c[19],co)  # was wrong direction, flipped

    # term 5

    # term 6

    # term 7
    add_requisite!(c[33],c[38],pre)

    curric = Curriculum("University of Kentucky EE Program", c)

    errors = IOBuffer()
    if is_valid(curric, errors)
        println("Curriculum $(curric.name) is valid")
        println("  delay factor = $(delay_factor(curric))")
        println("  blocking factor = $(blocking_factor(curric))")
        println("  centrality factor = $(centrality(curric))")
        println("  curricular complexity = $(complexity(curric))")

        terms = Array{Term}(undef, 8)
        terms[1] = Term([c[1],c[2],c[3],c[4],c[5],c[6]])
        terms[2] = Term([c[7],c[8],c[9],c[10],c[11]])
        terms[3] = Term([c[12],c[13],c[14],c[15],c[16]])
        terms[4] = Term([c[17],c[18],c[19],c[20],c[21]])
        terms[5] = Term([c[22],c[23],c[24],c[25],c[26],c[27]])
        terms[6] = Term([c[28],c[29],c[30],c[31],c[32]])
        terms[7] = Term([c[33],c[34],c[35],c[36],c[37]])
        terms[8] = Term([c[38],c[39],c[40],c[41],c[42],c[43]])

        dp = DegreePlan("University of Kentucky EE Program 4-year Plan", curric, terms)

        take!(errors) # clear the IO buffer
        if is_valid(dp, errors)
            println("Degree plan $(dp.name) is valid")
            return c, dp
        else
            println("Degree plan $(dp.name) is not valid:")
            print(String(take!(errors)))
            println("\nDiplaying degree plan for debugging purposes...")
        end

    else # invalid curriculum
        println("Curriculum $(curric.name) is not valid:")
        print(String(take!(errors)))
    end

end
