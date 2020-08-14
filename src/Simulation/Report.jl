
function simulation_report(simulation, duration, course_passrate, max_credits)
    println("\n------------ Simulation Report ------------")

    println("\n-------- Simulation Statistics --------")

    str = "Number of terms: " * string(duration)
    println(str)

    str = "Max Credits per Term: " * string(max_credits)
    println(str)

    str = "Number of Students: " * string(simulation.num_students)
    println(str)

    str = "Preset Course Pass Rates: " * string(course_passrate * 100) * "%"
    println(str)

    println("\n-------- Graduation Statistics --------")

    str = "Number of Students Graduated: " * string(length(simulation.graduated_students))
    println(str)

    str = "Graduation Rate: " * string(simulation.grad_rate * 100) * "%"
    println(str)

    println("Term Graduation Rates: ")
    println(simulation.term_grad_rates)

    str = "Average time to degree: " * string(round(simulation.time_to_degree, digits=2)) * " terms"
    println(str)

    println("\n-------- Stop out Statistics --------")

    str = "Number of Students Stopped Out: " * string(length(simulation.stopout_students))
    println(str)

    str = "Stop-out Rate: " * string(simulation.stopout_rate * 100) * "%"
    println(str)

    println("Term Stop-out Rates: ")
    println(simulation.term_stopout_rates)

    println("\n-------- Pass Rate of Each Course --------")

    frame = passrate_table(simulation)
    println(frame)

    println("\n-------- Course Pass Rates by Term --------")

    frame = pass_table(simulation, duration)
    println(frame)

    println("\n-------------------------------------------")
end

# Return the real passrate of courses in the simulation as a DataFrame
function passrate_table(simulation)
    courses = simulation.degree_plan.curriculum.courses

    course_names = []
    passrates = []
    for course in courses
        course_name = course.name
        course_prefix = course.prefix
        course_num = course.num

        if course_prefix != "" && course_num != ""
            course_name = "$(course_prefix) $(course_num) $(course_name)"
        end

        push!(course_names, course_name)
        push!(passrates, string(round(course.passrate * 100, digits=1)) * "%")
    end
    frame = DataFrame(Courses=course_names, PassRates=passrates)

    frame
end

# Return the simulated course passrate of each term as a DataFrame
function pass_table(simulation, semesters=-1)
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
    for course in simulation.degree_plan.curriculum.courses
        row = [course.name]
        prev = 0
        for i=1:terms
            prev += course.metadata["termpassed"][i]
            row = [row string(round((prev/simulation.num_students)*100, digits=3)) * "%"]
        end
        push!(frame, row)
    end

    rates = ["GRAD RATE"]
    for i=1:terms
        rates = [rates string(round(simulation.term_grad_rates[i]*100, digits=3)) * "%"]
    end
    push!(frame, rates)

    frame
end
