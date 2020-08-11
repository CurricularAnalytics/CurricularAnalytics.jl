module Enrollment
    using CurricularAnalytics: Student, Course, co, pre, strict_co, custom

    function enroll!(currentTerm, simulation, max_credits)
        studentProgress = simulation.studentProgress

        terms = simulation.degreePlan.terms
        courses = simulation.degreePlan.curriculum.courses

        for (termnum, term) in enumerate(terms)
            # Iterate through courses
            for course in term.courses
                # Clear the array of enrolled students for the course
                course.metadata["students"] = Student[]

                for student in simulation.enrolledStudents
                    # Get the coreqs of the the course
                    strictCoreqIds = [k for (k, v) in course.requisites if v == strict_co]

                    # Enroll in strictCoreqs first
                    for strictCoreqId in strictCoreqIds
                        strictCoreq = getCourseById(courses, strictCoreqId)

                        if canEnroll(student, strictCoreq, courses, studentProgress, max_credits, currentTerm)
                            # Enroll the student in the course
                            push!(strictCoreq.metadata["students"], student)

                            # Increment the course's enrollment counters
                            strictCoreq.metadata["enrolled"] += 1
                            strictCoreq.metadata["termenrollment"][currentTerm] += 1

                            # Increse the student's term credits
                            student.termcredits += strictCoreq.credit_hours
                        end
                    end

                    # Get the coreqs of the the course
                    coreqIds = [k for (k, v) in course.requisites if v == co]

                    # Enroll in coreqs
                    for coreqId in coreqIds
                        coreq = getCourseById(courses, coreqId)

                        if canEnroll(student, coreq, courses, studentProgress, max_credits, currentTerm)
                            # Enroll the student in the course
                            push!(coreq.metadata["students"], student)

                            # Increment the course's enrollment counters
                            coreq.metadata["enrolled"] += 1
                            coreq.metadata["termenrollment"][currentTerm] += 1

                            # Increse the student's term credits
                            student.termcredits += coreq.credit_hours
                        end
                    end



                    # Determine wheter the student can be enrolled in the current course.
                    if canEnroll(student, course, courses, studentProgress, max_credits, currentTerm)

                        # Enroll the student in the course
                        push!(course.metadata["students"], student)

                        # Increment the course's enrollment counters
                        course.metadata["enrolled"] += 1
                        course.metadata["termenrollment"][currentTerm] += 1

                        # Increse the student's term credits
                        student.termcredits += course.credit_hours
                    end
                end
            end
        end
    end

    # Function that determines wheter a student can enroll in a course
    function canEnroll(student, course, courses, studentProgress, max_credits, term)
        # Find the prereq ids of the current course
        prereqs = getReqs(courses, course, pre)
        prereqIds = map(x -> x.metadata["id"], prereqs)

        !in(student, course.metadata["students"]) &&
            (length(prereqIds) == 0 || sum(studentProgress[student.id, prereqIds]) == length(prereqIds)) &&     # No Prereqs or the student has completed them
            studentProgress[student.id, course.metadata["id"]] == 0.0 &&                                        # The student has not already completed the course
            !isStudentEnrolled(student, course) &&                                                              # The student has not already enrolled the course
            student.termcredits + course.credit_hours <= max_credits &&                                         # The student will not exceed the maximum number of credit hours
            course.metadata["termReq"] <= term &&                                                               # The student must wait until the term req has been met
            enrolledInCoreqs(student, course, courses, studentProgress)                                         # The student is enrolled in or has completed coreqs
    end

    # Determines whether a student is enrolled in or has completed coreqs for a given course
    function enrolledInCoreqs(student, course, courses, studentProgress)
        enrolled = true

        coreqs = getReqs(courses, course, strict_co)

        for coreq in coreqs
            enrolled =  enrolled && (in(student, course.metadata["students"]) || studentProgress[student.id, coreq.metadata["id"]] == 1.0)
        end

        return enrolled
    end

    # Determines whether a student is enrolled in a given course
    function isStudentEnrolled(targetStudent, course)
        students = course.metadata["students"]
        for student in students
            if student.id == targetStudent.id
                return true
            end
        end
        return false
    end


    # Get reqs of a given course
    function getReqs(courses, targetCourse, req)
        reqs = Course[]
        reqIds = []

        reqIds = [k for (k, v) in targetCourse.requisites if v == req]

        for reqId in reqIds
            course = getCourseById(courses, reqId)
            if course !== nothing
                push!(reqs, course)
            end
        end
        return reqs
    end

    # Find the course based on given id
    function getCourseById(courses, id)
        for course in courses
            if course.id == id
                return course
            end
        end
        return nothing
    end
end
