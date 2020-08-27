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

# Sets all course model passrates to given value
function set_passrates(courses, passrate)
    for course in courses
        course.passrate = passrate
    end
end

# Read from a CSV file that contains all courses taken by all students of a certain academic period
# Compute and set the pass rates for given courses based on the student performance in the file
# If a course is not found, set its pass rate to a preset value
# If a course is presented as a requirement (a set of courses), use the average pass rate of the set
# Note: Only support Tier I General Education for now
function set_passrates_from_csv(courses, csv_path, pass_rate)
    university_course_table = CSV.File(csv_path, delim = ',', silencewarnings = true) |> DataFrame

    passing_grades = ["A", "B", "C", "D", "P"]
    all_grades = ["A", "B", "C", "D", "P", "W", "F", "E", "S", "WS"]

    for course in courses
        prefix = string(strip(course.prefix))
        num = string(strip(course.num))

        # Compute the number of student passed the course, and number of student took the course
        num_passes = nrow(filter(row -> passrate_filter(row, prefix, num, passing_grades), university_course_table))
        num_students_taken = nrow(filter(row -> passrate_filter(row, prefix, num, all_grades), university_course_table))

        # The course is not found in the course table
        if (num_students_taken == 0)
            # The course is in a Tier I General Education, then use the average pass rate of them
            if (prefix == "" && num == "" && occursin("Tier I", course.name))
                course_passrate, num_passes, num_students_taken = get_gen_tier_I_passrate(university_course_table, ["150", "160"], passing_grades, all_grades, pass_rate)
                course.passrate = course_passrate
            else
                course.passrate = pass_rate                      # Hard code the rest of the course to a preset value for now
            end
        else
            course.passrate = num_passes / num_students_taken    # Computer the course pass rate
        end
        course.metadata["num_students_taken"] = num_students_taken
        course.metadata["num_students_passes"] = num_passes
    end
end

# Compute the average pass rate of Tier I General Education of given numbers
function get_gen_tier_I_passrate(university_course_table, nums, passing_grades, all_grades, pass_rate)
    # Compute the number of student passed the course, and number of student took the course
    num_passes = nrow(filter(row -> passrate_filter(row, nums, passing_grades), university_course_table))
    num_students_taken = nrow(filter(row -> passrate_filter(row, nums, all_grades), university_course_table))

    if (num_students_taken == 0)
        return pass_rate, 0, 0
    else
        return num_passes / num_students_taken, num_passes, num_students_taken
    end
end

# A course prefix, course number based filter. 
# The function returns true if the course taken by the student has the given prefix, number, and is in the grade range
function passrate_filter(row, prefix, num, grades)
    if row[:course_prefix] == prefix && row[:course_num] == num
        for grade in grades
            if row[:grade] == grade
                return true
            end
        end
    end
    return false
end

# A course number based filter. 
# The function returns true if the number of course taken by the student contains the given number, and is in the grade range
function passrate_filter(row, nums, grades)
    if start_with_nums(row[:course_num], nums)
        for grade in grades
            if row[:grade] == grade
                return true
            end
        end
    end
    return false
end

# Help function
function start_with_nums(str, nums)
    for num in nums
        if startswith(str, num)
            return true
        end
    end
    return false
end

# Set passrate for a given course
function set_passrate_for_course(course::Course, passrate::Float64)
    course.passrate = passrate
end

# set passrate based on given course prefix and number
function set_passrate_for_course(degree_plan::DegreePlan, course_prefix::AbstractString, course_num::AbstractString, passrate::Float64)
    courses = degree_plan.curriculum.courses
    course_found = false
    for course in courses
        if course.prefix == course_prefix && course.num == course_num
            course.passrate = passrate
            course_found = true
        end
    end
    return course_found
end