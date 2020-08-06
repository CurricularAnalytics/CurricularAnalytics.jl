mutable struct Student
    id::Int                     # Unique ID for student
    total_credits::Int          # The total number of credit hours the student has earned
    gpa::Float64                # The student's GPA
    total_points::Float64       # The total number of points the student has earned

    attributes::Dict            # A dictionary that can store any kind of student attribute
    stopout::Bool               # Indicates whether the student has stopped out. (False if the student has, True if still enrolled)
    stopsem::Bool               # The term the student stopped out.
    termcredits::Int            # The number of credits the student has enrolled in for a given term.
    performance::Dict           # Stores the grades the student has made in each course.
    graduated::Bool             # Indicates wheter the student has graduated.
    gradsem::Int                # The term the student has graduated.
    termpassed::Array{Int}      # An array that represents the term in which the student passed each course.


    # Constructor
    function Student(id::Int, attributes::Dict)
        this = new()
        this.id = id
        this.termcredits = 0
        this.performance = Dict()
        this.gpa = 0.0
        this.total_credits = 0
        this.total_points = 0
        this.attributes = attributes

        return this
    end
end

# Returns an array of students
function simpleStudents(number)
    students = Student[]
    for i = 1:number
        student = Student(i, Dict())
        push!(students, student)
    end
    return students
end
