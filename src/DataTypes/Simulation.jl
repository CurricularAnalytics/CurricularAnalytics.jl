import CurricularAnalytics: DegreePlan

mutable struct Simulation
    degreePlan::DegreePlan                  # The curriculum that is simulated  #GLH - this is actually a degree plan, is term info used in the simulation?
    duration::Int                           # The number of terms the simulation runs for

    predictionModel::Module                 # Module that implements the model for predicting student's performance in courses

    numStudents::Int                        # The number of students in the simulation
    enrolledStudents::Array{Student}        # Array of students that are enrolled
    graduatedStudents::Array{Student}       # Array of students that have graduated
    stopoutStudents::Array{Student}         # Array of students who stopped out

    studentProgress::Array{Int}             # Indicates wheter students have passed each course

    gradRate::Float64                       # Graduation rate at the end of the simulation
    termGradRates::Array{Float64}           # Array of graduation rates at the end of the simulation
    timeToDegree::Float64                   # Average number of terms it takes to graduate 
    stopoutRate::Float64                    # Stopout rate at the end of the simulation
    termStopoutRates::Array{Float64}        # Array of stopout rates for each term

    function Simulation(degreePlan)
        this = new()

        this.degreePlan = degreePlan

        this.enrolledStudents = Student[]
        this.graduatedStudents = Student[]
        this.stopoutStudents = Student[]

        # Set up degree plan
        degreePlan.metadata["stopoutModel"] = Dict()

        # Set up courses
        for (id, course) in enumerate(degreePlan.curriculum.courses)
            course.metadata["id"] = id
            course.metadata["failures"] = 0
            course.metadata["enrolled"] = 0
            course.metadata["passrate"] = 0
            course.metadata["termReq"] = 0
            course.metadata["grades"] = Float64[]
            course.metadata["students"] = Student[]
            course.metadata["model"] = Dict()
        end

        return this
    end
end
