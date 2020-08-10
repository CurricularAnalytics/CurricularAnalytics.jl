# Predicts whether a student will pass a course using the course's passrate
# as a probability.

module PassRate
    # Train the model
    function train(degree_plan)
        for course in degree_plan.curriculum.courses
            model = Dict()
            model[:passrate] = course.passrate
            course.metadata["model"]= model
        end

        degree_plan.metadata["stopout_model"][:rates] = [0.0838, 0.1334, 0.0465, 0.0631, 0.0368, 0.0189, 0.0165] * 100
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
    function predict_stopout(student, current_term, model)
        if current_term > 7
            return false
        else
            roll = rand(1:100)
            return roll <= model[:rates][current_term]
        end
    end
end


# Helper functions

# Sets all course model passrates to given value
function set_passrates(courses, passrate)
    for course in courses
        course.passrate = passrate
    end
end
