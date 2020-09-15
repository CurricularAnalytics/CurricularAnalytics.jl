##############################################################
# LearningOutcome data type
"""
The `LearningOutcome` data type is used to associate a set of learning outcomes with 
a course or a curriculum (i.e., degree program). To instantiate a `LearningOutcome` use:

    LearningOutcome(name, description, hours)

# Arguments
- `name::AbstractString` : the name of the learning outcome.
- `description::AbstractString` : detailed description of the learning outcome.
- `hours::int` : number of class (contact) hours needed to attain the learning outcome. 

# Examples:
```julia-repl
julia> LearningOutcome("M1", "Learner will demonstrate the ability to ...", 12)
```
"""
mutable struct LearningOutcome
    id::Int                             # Unique id for the learning outcome,
                                        # set when the cousrse is added to a graph
    name::AbstractString                # Name of the learning outcome
    description::AbstractString         # A description of the learning outcome
    hours::Int                          # number of class hours that should be devoted
                                        # to the learning outcome
    requisites::Dict{Int, Requisite}    # List of requisites, in
                                        #(requisite_learning_outcome, requisite_type) format
    metrics::Dict{String, Any}          # Learning outcome-related metrics
    metadata::Dict{String, Any}         # Learning outcome-related metadata

    # Constructor
    function LearningOutcome(name::AbstractString, description::AbstractString, hours::Int=0)
        this = new()
        this.name =name
        this.description = description
        this.hours = hours
        this.id = mod(hash(this.name * this.description), UInt32)
        this.requisites = Dict{Int, Requisite}()
        this.metrics = Dict{String, Any}()
        this.metadata = Dict{String, Any}()
        return this
    end
end

#"""
#add_lo_requisite!(rlo, tlo, requisite_type)
#Add learning outcome rlo as a requisite, of type requisite_type, for target learning outcome tlo 
#outcome tlo.
#"""
function add_lo_requisite!(requisite_lo::LearningOutcome, lo::LearningOutcome, requisite_type::Requisite)
    lo.requisites[requisite_lo.id] = requisite_type
end

function add_lo_requisite!(requisite_lo::Array{LearningOutcome}, lo::LearningOutcome, 
                      requisite_type::Array{Requisite})
    @assert length(requisite_lo) == length(requisite_type)
    for i = 1:length(requisite_lo)
        lo.requisites[requisite_lo[i].id] = requisite_type[i]
    end
end