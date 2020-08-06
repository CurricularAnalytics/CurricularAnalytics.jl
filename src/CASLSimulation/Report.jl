
function simulationReport(simulation, duration, course_passrate, max_credits)
    println()
    println("------------ Simulation Report ------------")

    println()
    println("-------- Simulation Statistics --------")

    str = "Number of terms: " * string(duration)
    println(str)

    str = "Max Credits per Semester: " * string(max_credits)
    println(str)

    str = "Number of Students: " * string(simulation.numStudents)
    println(str)

    str = "Course Pass Rates(same for all courses): " * string(course_passrate * 100) * "%"
    println(str)

    println()
    println("-------- Graduation Statistics --------")

    str = "Number of Graduated Students: " * string(length(simulation.graduatedStudents))
    println(str)

    str = "Graduate Rate: " * string(simulation.gradRate * 100) * "%"
    println(str)

    println("Term Graduation Rates: ")
    println(simulation.termGradRates)

    str = "Average number of semesters it takes to graduate students: " * string(simulation.timeToDegree)
    println(str)

    println()
    println("-------- Stopped out Statistics --------")

    str = "Number of Stopped out Students: " * string(length(simulation.stopoutStudents))
    println(str)

    str = "Stopped out Rate: " * string(simulation.stopoutRate * 100) * "%"
    println(str)

    println("Term Stopped out Rates: ")
    println(simulation.termStopoutRates)

    println()
    println("-------- Course Pass Rates of Terms Table--------")

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
