# GLH -- should not have to pass in duration course_passrate, and max_credit -- they should be stored as a part of a simulation object
# GLH -- need to be able to print course pass rates on a course-by-course basis
function simulationReport(simulation, duration, course_passrate, max_credits)
    println()
    println("------------ Simulation Report ------------")

    println()
    println("-------- Simulation Statistics --------")

    str = "Number of Terms: " * string(duration)
    println(str)

    str = "Max Credits per Semester: " * string(max_credits)
    println(str)

    str = "Number of Students: " * string(simulation.numStudents)
    println(str)

    str = "Course Pass Rates(same for all courses): " * string(course_passrate * 100) * "%"
    println(str)

    println()
    println("-------- Graduation Statistics --------")

    str = "Number of Students Graduated : " * string(length(simulation.graduatedStudents))
    println(str)

    str = "Graduate Rate: " * string(simulation.gradRate * 100) * "%"
    println(str)

    println("Term Graduation Rates: ")
    println(simulation.termGradRates)

    str = "Average time to degree: " * string(round(simulation.timeToDegree, digits=2)) * " terms"
    println(str)

    println()
    println("-------- Stop out Statistics --------")

    str = "Number of Students Stopped Out : " * string(length(simulation.stopoutStudents))
    println(str)

    str = "Stop-out Rate: " * string(simulation.stopoutRate * 100) * "%"
    println(str)

    println("Term Stop-out Rates: ")
    println(simulation.termStopoutRates)

    println()
    println("-------- Course Pass Rates by Term--------")

    frame = passTable(simulation, duration)
    println(frame)

    println()
    println("-------------------------------------------")
end


function passTable(simulation, semesters=-1)
    frame = DataFrame()

    # Make Keys
    frame[:COUSE] = []
    terms = simulation.duration

    if semesters > -1
        terms = semesters
    end

    for i=1:terms
        frame[Symbol("TERM$(i)")] = []
    end

    # Populate data
    for course in simulation.degreePlan.curriculum.courses
        row = [course.name]
        prev = 0
        for i=1:terms
            prev += course.metadata["termpassed"][i]
            # row = [row round((prev/simulation.numStudents)*100, digits=3)]
            row = [row string(round((prev/simulation.numStudents)*100, digits=3)) * "%"]
        end
        push!(frame, row)
    end

    rates = ["GRAD RATE"]
    for i=1:terms
        rates = [rates string(round(simulation.termGradRates[i]*100, digits=3)) * "%"]
        # rates = string([rates string(round(simulation.termGradRates[i]*100, digits=3)) * "%"])
    end
    push!(frame, rates)

    frame
end
