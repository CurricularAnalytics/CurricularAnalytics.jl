module Enrollment
    using CurricularAnalytics: Student, Course, co, pre, strict_co, custom

    function enroll!(current_term, simulation, max_credits)
        student_progress = simulation.student_progress

        terms = simulation.degree_plan.terms
        courses = simulation.degree_plan.curriculum.courses

        for (termnum, term) in enumerate(terms)
            # Iterate through courses
            for course in term.courses
                # Clear the array of enrolled students for the course
                course.metadata["students"] = Student[]

                for student in simulation.enrolled_students
                    
                    # Get the coreqs of the the course
                    strict_coreq_ids = [k for (k, v) in course.requisites if v == strict_co]

                    # Enroll in strictCoreqs first
                    for strict_coreq_id in strict_coreq_ids
                        strict_coreq = get_course_by_id(courses, strict_coreq_id)

                        if canEnroll(student, strict_coreq, courses, student_progress, max_credits, current_term)
                            # Enroll the student in the course
                            push!(strict_coreq.metadata["students"], student)

                            # Increment the course's enrollment counters
                            strict_coreq.metadata["enrolled"] += 1
                            strict_coreq.metadata["termenrollment"][current_term] += 1

                            # Increse the student's term credits
                            student.termcredits += strict_coreq.credit_hours
                        end
                    end

                    # Get the coreqs of the the course
                    coreq_ids = [k for (k, v) in course.requisites if v == co]

                    # Enroll in coreqs
                    for coreqId in coreq_ids
                        coreq = get_course_by_id(courses, coreqId)

                        if canEnroll(student, coreq, courses, student_progress, max_credits, current_term)
                            # Enroll the student in the course
                            push!(coreq.metadata["students"], student)

                            # Increment the course's enrollment counters
                            coreq.metadata["enrolled"] += 1
                            coreq.metadata["termenrollment"][current_term] += 1

                            # Increse the student's term credits
                            student.termcredits += coreq.credit_hours
                        end
                    end



                    # Determine wheter the student can be enrolled in the current course.
                    if canEnroll(student, course, courses, student_progress, max_credits, current_term)

                        # Enroll the student in the course
                        push!(course.metadata["students"], student)

                        # Increment the course's enrollment counters
                        course.metadata["enrolled"] += 1
                        course.metadata["termenrollment"][current_term] += 1

                        # Increse the student's term credits
                        student.termcredits += course.credit_hours
                    end
                end
            end
        end
    end

    # Function that determines wheter a student can enroll in a course
    function canEnroll(student, course, courses, student_progress, max_credits, term)
        # Find the prereq ids of the current course
        prereqs = get_reqs(courses, course, pre)
        prereq_ids = map(x -> x.metadata["id"], prereqs)

        # Stuent is enrolled already
        if in(student, course.metadata["students"])
            return false
        end

         # Student needs to complete prereqs
        if (length(prereq_ids) != 0 && sum(student_progress[student.id, prereq_ids]) != length(prereq_ids))
            return false
        end

        # The student has completed the course
        if student_progress[student.id, course.metadata["id"]] != 0.0
            return false
        end

        # The student will exceed the maximum number of credit hours
        if student.termcredits + course.credit_hours > max_credits
            return false
        end

        # The student must wait until the term req has been met
        if course.metadata["term_req"] > term
            return false
        end

        # The student isn't enrolled in or hasn't completed coreqs
        if !enrolled_in_coreqs(student, course, courses, student_progress)
            return false
        end

        return true
    end

    # Determines whether a student is enrolled in or has completed coreqs for a given course
    function enrolled_in_coreqs(student, course, courses, student_progress)
        enrolled = true

        coreqs = get_reqs(courses, course, strict_co)

        for coreq in coreqs
            enrolled =  enrolled && (in(student, course.metadata["students"]) || student_progress[student.id, coreq.metadata["id"]] == 1.0)
        end

        return enrolled
    end
    
    # Get reqs of a given course
    function get_reqs(courses, target_course, req)
        reqs = Course[]
        req_ids = []

        req_ids = [k for (k, v) in target_course.requisites if v == req]

        for req_id in req_ids
            course = get_course_by_id(courses, req_id)
            if course !== nothing
                push!(reqs, course)
            end
        end
        return reqs
    end

    # Find the course based on given id
    function get_course_by_id(courses, id)
        for course in courses
            if course.id == id
                return course
            end
        end
        return nothing
    end
end
