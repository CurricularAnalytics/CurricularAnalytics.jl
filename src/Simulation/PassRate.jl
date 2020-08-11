# Predicts whether a student will pass a course using the course's passrate
# as a probability.

module PassRate
    # Train the model
    function train(degreePlan)
        for course in degreePlan.curriculum.courses
            model = Dict()
            model[:passrate] = course.passrate
            course.metadata["model"]= model
        end

        degreePlan.metadata["stopoutModel"][:rates] = [0.0838, 0.1334, 0.0465, 0.0631, 0.0368, 0.0189, 0.0165] * 100
    end

    # Predict grade
    function predict_grade(course, student)
        roll = rand()

        if roll <= course.metadata["model"][:passrate]
            return 4.0
        else
            return 0.0
        end
    end

    # Predict stopout
    function predict_stopout(student, currentTerm, model)
        if currentTerm > 7
            return false
        else
            roll = rand(1:100)
            return roll <= model[:rates][currentTerm]
        end
    end
end


# Helper functions

# Sets all course model passrates to given value
function setPassrates(courses, passrate)
    for course in courses
        course.passrate = passrate
    end
end
