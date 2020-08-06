module Enrollment
    using CurricularAnalytics: Student, Course, co, pre, strict_co

    function enroll!(currentTerm, simulation, max_credits)
        studentProgress = simulation.studentProgress

        terms = simulation.degreePlan.terms
        courses = simulation.degreePlan.curriculum.courses

        for (termnum, term) in enumerate(terms)
            # Itterate through courses
            for course in term.courses
                # Clear the array of enrolled students for the course
                course.metadata["students"] = Student[]

                # Get the coreqs of the the course
                coreqIds = [k for (k, v) in course.requisites if v == co || v == strict_co]

                for student in simulation.enrolledStudents
                    # Enroll in coreqs first
                    for coreqId in coreqIds
                        coreq = getCourseById(courses, coreqId)

                        if canEnroll(student, coreq, courses, studentProgress, max_credits, currentTerm)
                            # Enroll the student in the course
                            push!(course.metadata["students"], student)

                            # Increment the course's enrollment counters
                            course.metadata["enrolled"] += 1
                            course.metadata["termenrollment"][currentTerm] += 1

                            # Increse the student's term credits
                            student.termcredits += course.credit_hours
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
        # prereqIds = [k for (k, v) in course.requisites if v == pre]

        prereqs = getReqs(courses, course, pre)
        prereqIds = map(x -> x.metadata["id"], prereqs)


        !in(student, course.metadata["students"]) &&
            (length(prereqIds) == 0 || sum(studentProgress[student.id, prereqIds]) == length(prereqIds)) &&                 # No Prereqs or the student has completed them
            studentProgress[student.id, course.metadata["id"]] == 0.0 &&                                                                # The student has not already completed the course
            student.termcredits + course.credit_hours <= max_credits &&                                                          # The student will not exceed the maximum number of credit hours
            course.metadata["termReq"] <= term &&                                                                                       # The student must wait until the term req has been met
            enrolledInCoreqs(student, course, courses, studentProgress)                                                              # The student is enrolled in or has completed coreqs
    end

    # Determines whether a student is enrolled in or has completed coreqs for a given course
    function enrolledInCoreqs(student, course, courses, studentProgress)
        enrolled = true

        coreqs = getReqs(courses, course, co)

        for coreq in coreqs
            enrolled =  enrolled && (in(student, course.metadata["students"]) || studentProgress[student.id, coreq.metadata["id"]] == 1.0)
        end

        return enrolled
    end


    # Get coreqs of a given course
    function getReqs(courses, targetCourse, req)
        coreqs = Course[]
        coreqIds = [k for (k, v) in targetCourse.requisites if v == req]
        if req == co
            coreqIds = [k for (k, v) in targetCourse.requisites if v == co || v == strict_co]
        end

        for coreqId in coreqIds
            course = getCourseById(courses,coreqId)
            if course !== nothing
                push!(coreqs, course)
            end
        end
        return coreqs
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
