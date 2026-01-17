
# Course record - record of performance in a single course
mutable struct CourseRecord
    course::Course                      # course that was attempted
    grade::Grade                        # grade earned in the course
    term::AbstractString                # term course was attempted

    # Constructor
    function CourseRecord(course::Course, grade::Grade, term::AbstractString="")
        this = new()
        this.course = course
        this.grade = grade
        this.term = term
        return this
    end
end

# Student record data type, i.e., a transcript
mutable struct StudentRecord
    id::AbstractString                  # unique student id
    first_name::AbstractString          # student's first name
    last_name::AbstractString           # student's last name
    middle_initial::AbstractString      # Student's middle initial or name
    transcript::Array{CourseRecord}     # list of student grades
    GPA::Real                           # student's GPA

    # Constructor
    function StudentRecord(id::AbstractString, first_name::AbstractString, last_name::AbstractString, middle_initial::AbstractString,
                         transcript::Array{CourseRecord,1})
        this = new()
        this.first_name = first_name
        this.last_name = last_name
        this.middle_initial = middle_initial
        this.transcript = transcript
        return this
    end
end