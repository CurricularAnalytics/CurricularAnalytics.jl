#File: DegreeRequirementsAnalytics.jl

# Pre-order traverse a requirement tree, performing visit() on each requirement 
function preorder_traversal(root::AbstractRequirement, visit::Function = x -> nothing)
    if typeof(root) == CourseSet || length(root.requirements) == 0
        return [root]
    end   
    stack = Array{AbstractRequirement,1}([root])
    visit_order = Array{AbstractRequirement,1}()
    while (length(stack) != 0)
        req = pop!(stack)
        visit(req)
        push!(visit_order, req)
        if typeof(req) == RequirementSet # course-set requirements have no children
            for r in reverse(req.requirements)
                push!(stack, r)
            end
        end
    end
    return visit_order
end

# Post-order traverse a requirement tree, performing visit() on each requirement 
function postorder_traversal(root::AbstractRequirement, visit::Function = x -> nothing)
    if typeof(root) == CourseSet || length(root.requirements) == 0
        return [root]
    end   
    stack = Array{AbstractRequirement,1}([root])
    visit_order = Array{AbstractRequirement,1}()
    while (length(stack) != 0)
        req = pop!(stack)
        push!(visit_order, req)
        if typeof(req) == RequirementSet  # course-set requirements have no children
            for r in req.requirements
                push!(stack, r)
            end
        end
    end
    for r in reverse(visit_order)
        visit(r)
    end
    return reverse(visit_order)
end

# Determine the level of requirement req in a requirement tree rooted at root.
# Uses two queues to search the requirement tree level by level, the count_que keeps track of how many requirements are on a given level.
function level(root::AbstractRequirement, req::AbstractRequirement)
    req_que = Queue{AbstractRequirement}()
    enqueue!(req_que, root)
    counter = 1
    count_que = Queue{Int}()
    level = 1
    while (length(req_que) != 0)
        r = dequeue!(req_que)
        counter = counter - 1
        if r.id == req.id
            return level
        else
            if typeof(r) == RequirementSet
                enqueue!(count_que, length(r.requirements))
                for c in r.requirements
                    enqueue!(req_que, c)
                end
            end
        end
        if counter == 0  # finished processing a level
            level = level + 1
            while length(count_que) != 0
                counter = counter + dequeue!(count_que)  # total number of requirement sets in the current level
            end
        end
    end
    return nothing
end

"""
Formatted print of the requirements associated with a requirements tree.

    show_requirements(root; <keyword agruments>)

# Arguments
Required:
- `root::AbstractRequirement` : the root of the requirements tree.
Keyword:
- `tab::String` : the string to use for tabbing.
    default is three spaces.
- `satisfied:Dict{Int,Bool}` : a dictionary with format degree requirement id => (satisfaction code, array of satisfying courses), with 
satisfaction code 0 indicating the degree requirement is not satisfied, 1 indicating it is, and 2 indicating the degree requirement is only 
partially satisfied.  If this argument is supplied, a color-code annotation is also added beside each requirement, indicating the satisfaction 
status of each degree requirement.  Note: the `satisfied` function can be used to create to create a `satisfied` dictionary.
- `display_limit::Int` : limit on the number of courses displayed from a `CourseSet` requirement.  

# Examples:
```julia-repl
julia> model = assign_courses(transcript, program_requirements, applied_credits) 
julia> x = model.obj_dict[:x]
julia> is_satisfied = Dict{Int,Tuple{Int,Array{Int,1}}}() 
julia> satisfied(program_requirements, coalesce_transcript(transcript), flatten_requirements(program_requirements), value.(x), is_satisfied)
julia> show_requirement(program_requirements, satisfied=is_satisfied)
````
"""
function show_requirements(
    root::AbstractRequirement;
    io::IO = stdout,
    tab = "   ",
    satisfied::Dict{Int,Tuple{Int,Array{Int,1}}} = Dict{Int,Tuple{Int,Array{Int,1}}}(),
    display_limit::Int = 500,
)
    for req in preorder_traversal(root)
        depth = level(root, req)
        tabs = tab^depth
        print(io, tabs * " ├-")
        printstyled(io, "$(req.name) "; bold = true)
        if haskey(satisfied, req.id) 
            if satisfied[req.id][1] == 2 
                printstyled(io, "[satisfied] "; color = :green)
            elseif satisfied[req.id][1] == 0
                printstyled(io, "[not satisfied] "; color = :red)
            elseif satisfied[req.id][1] == 1
                printstyled(io, "[partially satisfied] "; color = :yellow)
            end
        end 
        if req.description != ""
            print(io, "($(req.description), requires: $(req.credit_hours) credit hours)")
        else
            print(io, "($(req.credit_hours) credit hours)")
        end
        if typeof(req) == RequirementSet
            if req.satisfy < length(req.requirements)
                print(io, ", satisfy: $(req.satisfy) of $(length(req.requirements)) subrequirements\n",)
            else
                print(io, ", satisfy: all $(length(req.requirements)) subrequirements\n")
            end
        else # requirement is a CourseSet
            print(io, "\n")
            for (i, c) in enumerate(req.course_reqs)
                print(io, tabs * tab * "  ├-")
                if i <= display_limit
                    if (haskey(satisfied, req.id))
                        c[1].id ∈ satisfied[req.id][2] ? color = :green : color = :black 
                    else # satisfed not passed to the function
                        color = :black 
                    end
                    c[1].prefix != "" ? printstyled(io, "$(c[1].prefix) ", color = color) : nothing 
                    c[1].num != "" ? printstyled(io, "$(c[1].num) ", color = color) : nothing 
                    printstyled(io, "$(c[1].name) ($(c[1].credit_hours) credit hours), minimum grade: $(grade(c[2]))\n", color=color)
                else
                    println(io, "Course list truncated to $(display_limit) courses...")
                    break
                end
            end
        end
    end
end