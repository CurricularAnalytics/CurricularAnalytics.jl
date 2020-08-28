using DataFrames
using LightGraphs

include("PassRate.jl")
include("Enrollment.jl")
include("Report.jl")

# Simulation Function
function simulate(degree_plan::DegreePlan, course_attempt_limit::Int, students::Array{Student}; performance_model=PassRate, enrollment_model=Enrollment, max_credits=18, duration=8, duration_lock=false, stopouts=false)

    # Create the simulation object
    simulation = Simulation(deepcopy(degree_plan))

    # Train the model
    performance_model.train(simulation.degree_plan)

    simulation.course_attempt_limit = course_attempt_limit

    # Determine the number of students used in the simulation
    num_students = length(students)
    simulation.num_students = num_students

    # Populate the enrolled students array with all students
    simulation.enrolled_students = deepcopy(students)

    # Reset simulation object
    simulation.graduated_students = Student[]
    simulation.stopout_students = Student[]
    simulation.reach_attempts_students = Student[]
    simulation.grad_rate = 0.0
    simulation.term_grad_rates = zeros(duration)
    simulation.stopout_rate = 0.0
    simulation.term_stopout_rates = zeros(duration)
    simulation.reach_attempts_rates = zeros(duration)

    num_courses = simulation.degree_plan.curriculum.num_courses

    # Assign each student a unique id
    for (i, student) in enumerate(simulation.enrolled_students)
        student.id = i
        student.termpassed = zeros(num_courses)
    end

    # Initialize matrix to track student performance
    # Each row represents a student and each column is associated with a course.
    # A 1 signifies that the student passed the course while a 0 indicates incomplete.
    simulation.student_progress = zeros(num_students, num_courses)

    # Matrix to hold the number of attempts a student has made at passing a course
    simulation.student_attemps = ones(num_students, num_courses)

    # Record number of simulation terms
    simulation.duration = duration

    # Initialize courses
    for course in simulation.degree_plan.curriculum.courses
        course.metadata["termenrollment"] = zeros(duration)
        course.metadata["termpassed"] = zeros(duration)
        course.metadata["students"] = Student[]
    end

    # Convenience variables
    terms = simulation.degree_plan.terms
    student_progress = simulation.student_progress
    student_attemps = simulation.student_attemps

    # Begin simulation
    for current_term = 1:duration
        # Enroll students in courses
        enrollment_model.enroll!(current_term, simulation, max_credits)

        # Predict Performance
        for (termnum, term) in enumerate(terms)
            for course in term.courses
                for student in course.metadata["students"]
                    # Make prediction
                    predicted_grade = performance_model.predict_grade(course, student)

                    course_name = construct_course_name(course.prefix, course.num, course.name)
                    student.performance[course_name] = predicted_grade

                    # Record grade for the course
                    push!(course.metadata["grades"], predicted_grade)

                    # Check to see if the grade is passing
                    if predicted_grade > 1.67
                        # Mark that the student passed the course
                        student_progress[student.id, course.metadata["id"]] = 1.0

                        # Log the term which the student passed the course
                        course.metadata["termpassed"][current_term] += 1

                        student.termpassed[course.metadata["id"]] = current_term
                    else
                        # Record the failure
                        course.metadata["failures"] += 1

                        # Check if the student have reached max attempts for a course
                        attempts = student_attemps[student.id, course.metadata["id"]]
                        if attempts == course_attempt_limit
                            push!(simulation.reach_attempts_students, student)
                            # Student has to stopout
                            student.stopout = true
                        end
                        # Increment the attempts
                        student_attemps[student.id, course.metadata["id"]] += 1
                    end

                    # Increment the students credit hours and points
                    student.total_credits += course.credit_hours
                    student.total_points += predicted_grade * course.credit_hours
                end
            end
        end


        # Process term performance
        for student in simulation.enrolled_students
            # Compute the student's GPA
            student.gpa = student.total_points / student.total_credits

            # Reset the student's term credits to 0
            student.termcredits = 0
        end


        # Determine whether a student has graduated
        graduated_student_ids = []
        for (i, student) in enumerate(simulation.enrolled_students)
            if sum(student_progress[student.id, :]) == num_courses
                # Add the student to the array of graduated students
                push!(simulation.graduated_students, student)

                # Record the semester of graduation
                student.gradsem = current_term

                # Record the index of the student
                push!(graduated_student_ids, i)

                simulation.time_to_degree += current_term
            end
        end
        # Remove graduated students from enrolled array
        deleteat!(simulation.enrolled_students, graduated_student_ids)

        # Compute graduation rate as of the current term
        simulation.term_grad_rates[current_term] = length(simulation.graduated_students) / num_students


        # Determine stopouts
        if stopouts
            stopout_student_ids = []
            for (i, student) in enumerate(simulation.enrolled_students)
                # Predict stopout for students who haven't decided to stopout
                if student.stopout == false
                    student.stopout = performance_model.predict_stopout(student, current_term, simulation.degree_plan.metadata["stopout_model"])
                end

                if student.stopout
                    # Add to array of stopouts
                    push!(simulation.stopout_students, student)

                    # Record index of the student
                    push!(stopout_student_ids, i)
                end
            end

            # Remove stoped-out students from the array of enrolled students
            deleteat!(simulation.enrolled_students, stopout_student_ids)

            # Compute stopout rate as of the current term
            simulation.term_stopout_rates[current_term] = length(simulation.stopout_students) / num_students
        end

        # Compute reach course max attampts rate of the current term
        simulation.reach_attempts_rates[current_term] = round(length(simulation.reach_attempts_students) / num_students, digits=3)

        # Check to see if all students have graduated
        if length(simulation.enrolled_students) == 0 && !duration_lock
            simulation.duration = current_term
            break  # breaks out of the simulation loop, i.e., stops the simulation
        end
    end

    # Compute graduation rate
    simulation.grad_rate = length(simulation.graduated_students) / num_students

    # Compute stopout rate
    simulation.stopout_rate = length(simulation.stopout_students) / num_students

    # Compute average time to degree 
    simulation.time_to_degree /= length(simulation.graduated_students)

    return simulation
end


# Helper funcions
function construct_course_name(prefix, num, name)
    return prefix * " " * string(num) * " " * name
end
