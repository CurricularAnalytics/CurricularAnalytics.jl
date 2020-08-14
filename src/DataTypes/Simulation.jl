import CurricularAnalytics: DegreePlan

mutable struct Simulation
    degree_plan::DegreePlan                # The curriculum that is simulated
    duration::Int                           # The number of terms the simulation runs for

    prediction_model::Module                 # Module that implements the model for predicting student's performance in courses

    num_students::Int                        # The number of students in the simulation
    enrolled_students::Array{Student}        # Array of students that are enrolled
    graduated_students::Array{Student}       # Array of students that have graduated
    stopout_students::Array{Student}         # Array of students who stopped out

    student_progress::Array{Int}             # Indicates wheter students have passed each course

    grad_rate::Float64                       # Graduation rate at the end of the simulation
    term_grad_rates::Array{Float64}           # Array of graduation rates at the end of the simulation
    time_to_degree::Float64                   # Average number of semesters it takes to graduate students
    stopout_rate::Float64                    # Stopout rate at the end of the simulation
    term_stopout_rates::Array{Float64}        # Array of stopout rates for each term

    function Simulation(degree_plan)
        this = new()

        this.degree_plan = degree_plan

        this.enrolled_students = Student[]
        this.graduated_students = Student[]
        this.stopout_students = Student[]

        # Set up degree plan
        degree_plan.metadata["stopout_model"] = Dict()

        # Set up courses
        for (id, course) in enumerate(degree_plan.curriculum.courses)
            course.metadata["id"] = id
            course.metadata["failures"] = 0
            course.metadata["enrolled"] = 0
            course.metadata["passrate"] = 0
            course.metadata["term_req"] = 0
            course.metadata["grades"] = Float64[]
            course.metadata["students"] = Student[]
            course.metadata["model"] = Dict()
        end

        return this
    end
end
