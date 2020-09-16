"""
The curriculum-based metrics in this toolbox are based upon the graph structure of a
curriculum.  Specifically, assume curriculum ``c`` consists of ``n`` courses ``\\{c_1, \\ldots, c_n\\}``,
and that there are ``m`` requisite (prerequisite or co-requsitie) relationships between these courses.
A curriculum graph ``G_c = (V,E)`` is formed by creating a vertex set ``V = \\{v_1, \\ldots, v_n\\}``
(i.e., one vertex for each course) along with an edge set ``E = \\{e_1, \\ldots, e_m\\}``, where a
directed edge from vertex ``v_i`` to ``v_j`` is in ``E`` if course ``c_i`` is a requisite for course ``c_j``.
"""
module CurricularAnalytics

# Dependencies
using LightGraphs
using DataStructures
using Printf
using Markdown
using Documenter
using Dates

include("DataTypes/DataTypes.jl")
include("DataHandler.jl")
include("GraphAlgs.jl")
include("DegreePlanAnalytics.jl")
include("DegreePlanCreation.jl")
include("Simulation/Simulation.jl")

export AA, AAS, AS, AbstractCourse, AbstractRequirement, BA, BS, Course, CourseCollection, CourseCatalog, CourseRecord, CourseSet, Curriculum, Degree, DegreePlan, 
        EdgeClass, Enrollment, Grade, LearningOutcome, PassRate, RequirementSet, Requisite, Student, StudentRecord, Simulation, System, Term, TransferArticulation,
        add_course!, add_lo_requisite!, add_requisite!, add_transfer_catalog, add_transfer_course, all_paths, back_edge, basic_metrics, basic_statistics, 
        bin_filling, blocking_factor, centrality, co, compare_curricula, convert_ids, complexity, course, course_from_id, course_from_vertex, course_id, 
        courses_from_vertices, create_degree_plan, cross_edge, dead_ends, delay_factor, delete_requisite!, dfs, extraneous_requisites, find_term, forward_edge, 
        gad, grade, homology, is_duplicate, isvalid_curriculum, isvalid_degree_plan, longest_path, longest_paths, merge_curricula, pass_table, passrate_table, 
        pre, print_plan, quarter, reach, reach_subgraph, reachable_from, reachable_from_subgraph, reachable_to, reachable_to_subgraph, read_csv, requisite_distance,
        requisite_type, semester, set_passrates, set_passrate_for_course, set_passrates_from_csv, similarity, simple_students, simulate, simulation_report, 
        strict_co, topological_sort, total_credits, transfer_equiv, tree_edge, write_csv

# Check if a curriculum graph has requisite cycles.
"""
    isvalid_curriculum(c::Curriculum, errors::IOBuffer)

Tests whether or not the curriculum graph ``G_c`` associated with curriculum `c` is valid, i.e.,
whether or not it contains a requisite cycle.  Returns  a boolean value, with `true` indicating the
curriculum is valid, and `false` indicating it is not.

If ``G_c`` is not valid, the requisite cycle(s) are written to the `errors` buffer. To view these
cycles, use:

```julia-repl
julia> errors = IOBuffer()
julia> isvalid_curriculum(c, errors)
julia> println(String(take!(errors)))
```

A curriculum graph is not valid if it contains a directed cycle; in this case it is not possible to complete
the curriculum.
"""
function isvalid_curriculum(c::Curriculum, error_msg::IOBuffer=IOBuffer())
    g = c.graph
    validity = true
    # first check for cycles
    cycles = simplecycles(g)
    if size(cycles,1) != 0
        validity = false
        c.institution != "" ? write(error_msg, "\n$(c.institution): ") : "\n"
        write(error_msg, " curriculum \'$(c.name)\' has requisite cycles:\n")
        for cyc in cycles
            write(error_msg, "(")
            for (i,v) in enumerate(cyc)
                if i != length(cyc)
                    write(error_msg, "$(c.courses[v].name), ")
                else
                    write(error_msg, "$(c.courses[v].name))\n")
                end
            end
        end
    end
    return validity
end

## refactoring this out of the function above, to reduce warning outputs -- use extraneous_requisites() in its place
#else # no cycles, can now check for extraneous requisites
#        extran_errors = IOBuffer()
#        if extraneous_requisites(c, extran_errors)
#            validity = false
#            c.institution != "" ? write(error_msg, "\n$(c.institution): ") : "\n"
#            write(error_msg, " curriculum \'$(c.name)\' has extraneous requisites:\n")
#            write(error_msg, String(take!(extran_errors)))
#        end
#    end
#    return validity
#end

"""
    extraneous_requisites(c::Curriculum; print=false)

Determines whether or not a curriculum `c` contains extraneous requisites, and returns them.  Extraneous requisites
are redundant requisites that are unnecessary in a curriculum.  For example, if a curriculum has the prerequisite
relationships \$c_1 \\rightarrow c_2 \\rightarrow c_3\$ and \$c_1 \\rightarrow c_3\$, and \$c_1\$ and \$c_2\$ are
*not* co-requisites, then \$c_1 \\rightarrow c_3\$ is redundant and therefore extraneous.
"""
function extraneous_requisites(c::Curriculum; print=false)
    if is_cyclic(c.graph)
        error("\nCurriculm graph has cycles, extraneous requisities cannot be determined.")
    end
    if print == true
        msg = IOBuffer()
    end
    redundant_reqs = Array{Array{Int,1},1}()
    g = c.graph
    que = Queue{Int}()
    components = weakly_connected_components(g)
    extraneous = false
    str = "" # create an empty string to hold messages
    for wcc in components
        if length(wcc) > 1  # only consider components with more than one vertex
            for u in wcc
                nb = neighbors(g,u)
                for n in nb
                    enqueue!(que, n)
                end
                while !isempty(que)
                    x = dequeue!(que)
                    nnb = neighbors(g,x)
                    for n in nnb
                        enqueue!(que, n)
                    end
                    for v in neighbors(g, x)
                        if has_edge(g, u, v)  # possible redundant requsisite
                            # TODO: If this edge is a co-requisite it is an error, as it would be impossible to satsify.
                            # This needs to be checked here.
                            remove = true
                            for n in nb  # check for co- or strict_co requisites
                                if has_path(c.graph, n, v) # is there a path from n to v?
                                    req_type = c.courses[n].requisites[c.courses[u].id] # the requisite relationship between u and n
                                    if (req_type == co) || (req_type == strict_co)  # is u a co or strict_co requisite for n?
                                        remove = false # a co or strict_co relationshipo is involved, must keep (u, v)
                                    end
                                end
                            end
                            if remove == true
                                if findfirst(x -> x == [c.courses[u].id, c.courses[v].id], redundant_reqs) == nothing  # make sure redundant requisite wasn't previously found
                                    push!(redundant_reqs, [c.courses[u].id, c.courses[v].id])
                                    if print == true
                                        str = str * "-$(c.courses[v].name) has redundant requisite $(c.courses[u].name)\n"
                                    end
                                end
                                extraneous = true
                            end
                        end
                    end
                end
            end
        end
    end
    if (extraneous == true) && (print == true)
        c.institution != "" ? write(msg, "\n$(c.institution): ") : "\n"
        write(msg, "curriculum $(c.name) has extraneous requisites:\n")
        write(msg, str)
    end
    if print == true
        println(String(take!(msg)))
    end
    return redundant_reqs
end

# Compute the blocking factor of a course
"""
    blocking_factor(c::Curriculum, course::Int)

The **blocking factor** associated with course ``c_i`` in curriculum ``c`` with
curriculum graph ``G_c = (V,E)`` is defined as:
```math
b_c(v_i) = \\sum_{v_j \\in V} I(v_i,v_j)
```
where ``I(v_i,v_j)`` is the indicator function, which is ``1`` if  ``v_i \\leadsto v_j``,
and ``0`` otherwise. Here ``v_i \\leadsto v_j`` denotes that a directed path from vertex
``v_i`` to ``v_j`` exists in ``G_c``, i.e., there is a requisite pathway from course
``c_i`` to ``c_j`` in curriculum ``c``.
"""
function blocking_factor(c::Curriculum, course::Int)
    b = length(reachable_from(c.graph, course))
    return c.courses[course].metrics["blocking factor"] = b
end

# Compute the blocking factor of a curriculum
"""
    blocking_factor(c::Curriculum)

The **blocking factor** associated with curriculum ``c`` is defined as:
```math
b(G_c) = \\sum_{v_i \\in V} b_c(v_i).
```
where ``G_c = (V,E)`` is the curriculum graph associated with curriculum ``c``.
"""
function blocking_factor(c::Curriculum)
    b = 0
    bf = Array{Int, 1}(undef, c.num_courses)
    for (i, v) in enumerate(vertices(c.graph))
        bf[i] = blocking_factor(c, v)
        b += bf[i]
    end
    return c.metrics["blocking factor"] = b, bf
end

# Compute the delay factor of a course
"""
    delay_factor(c::Curriculum, course::Int)

The **delay factor** associated with course ``c_k`` in curriculum ``c`` with
curriculum graph ``G_c = (V,E)`` is the number of vertices in the longest path
in ``G_c`` that passes through ``v_k``. If ``\\#(p)`` denotes the number of
vertices in the directed path ``p`` in ``G_c``, then we can define the delay factor of
course ``c_k`` as:
```math
d_c(v_k) = \\max_{i,j,l,m}\\left\\{\\#(v_i  \\overset{p_l}{\\leadsto} v_k \\overset{p_m}{\\leadsto} v_j)\\right\\}
```
where ``v_i \\overset{p}{\\leadsto} v_j`` denotes a directed path ``p`` in ``G_c`` from vertex
``v_i`` to ``v_j``.
"""
function delay_factor(c::Curriculum, course::Int)
    if !haskey(c.courses[course].metrics, "delay factor")
        delay_factor(c)
    end
    return c.courses[course].metrics["delay factor"]
end

# Compute the delay factor of a curriculum
"""
    delay_factor(c::Curriculum)

The **delay factor** associated with curriculum ``c`` is defined as:
```math
d(G_c) = \\sum_{v_k \\in V} d_c(v_k).
```
where ``G_c = (V,E)`` is the curriculum graph associated with curriculum ``c``.
"""
function delay_factor(c::Curriculum)
    g = c.graph
    df = ones(c.num_courses)
    for v in vertices(g)
        for path in all_paths(g)
            for vtx in path
                path_length = length(path)  # path_length in terms of # of vertices, not edges
                if path_length > df[vtx]
                    df[vtx] = path_length
                end
            end
        end
    end
    d = 0
    c.metrics["delay factor"] = 0
    for v in vertices(g)
        c.courses[v].metrics["delay factor"] = df[v]
        d += df[v]
    end
    return c.metrics["delay factor"] = d, df
end

# Compute the centrality of a course
"""
    centrality(c::Curriculum, course::Int)

Consider a curriculum graph ``G_c = (V,E)``, and a vertex ``v_i \\in V``. Furthermore,
consider all paths between every pair of vertices ``v_j, v_k \\in V`` that satisfy the
following conditions:
- ``v_i, v_j, v_k`` are distinct, i.e., ``v_i \\neq v_j, v_i \\neq v_k`` and ``v_j \\neq v_k``;
- there is a path from ``v_j`` to ``v_k`` that includes ``v_i``, i.e., ``v_j \\leadsto v_i \\leadsto v_k``;
- ``v_j`` has in-degree zero, i.e., ``v_j`` is a "source"; and
- ``v_k`` has out-degree zero, i.e., ``v_k`` is a "sink".
Let ``P_{v_i} = \\{p_1, p_2, \\ldots\\}`` denote the set of all directed paths that satisfy these
conditions.
Then the **centrality** of ``v_i`` is defined as
```math
q(v_i) = \\sum_{l=1}^{\\left| P_{v_i} \\right|} \\#(p_l).
```
where ``\\#(p)`` denotes the number of vertices in the directed path ``p`` in ``G_c``.
"""
function centrality(c::Curriculum, course::Int)
    cent = 0; g = c.graph
    for path in all_paths(g)
        # conditions: path length is greater than 2, target course must be in the path, the target vertex
        # cannot be the first or last vertex in the path
        if (in(course,path) && length(path) > 2 && path[1] != course && path[end] != course)
            cent += length(path)
        end
    end
    return c.courses[course].metrics["centrality"] = cent
end

# Compute the total centrality of all courses in a curriculum
"""
    centrality(c::Curriculum)

Computes the total **centrality** associated with all of the courses in curriculum ``c``,
with curriculum graph ``G_c = (V,E)``.
```math
q(c) = \\sum_{v \\in V} q(v).
```
"""
function centrality(c::Curriculum)
    cent = 0
    cf = Array{Int, 1}(undef, c.num_courses)
    for (i, v) in enumerate(vertices(c.graph))
        cf[i] = centrality(c, v)
        cent += cf[i]
    end
    return c.metrics["centrality"] = cent, cf
end

# Compute the complexity of a course
"""
    complexity(c::Curriculum, course::Int)

The **complexity** associated with course ``c_i`` in curriculum ``c`` with
curriculum graph ``G_c = (V,E)`` is defined as:
```math
h_c(v_i) = d_c(v_i) + b_c(v_i)
```
i.e., as a linear combination of the course delay and blocking factors.
"""
function complexity(c::Curriculum, course::Int)
    if !haskey(c.courses[course].metrics, "complexity")
        complexity(c)
    end
    return c.courses[course].metrics["complexity"]
end

# Compute the complexity of a curriculum
"""
    complexity(c::Curriculum, course::Int)

The **complexity** associated with curriculum ``c`` with  curriculum graph ``G_c = (V,E)``
is defined as:

```math
h(G_c) = \\sum_{v \\in V} \\left(d_c(v) + b_c(v)\\right).
```

For the example curricula considered above, the curriculum in part (a) has an overall complexity of 15,
while the curriculum in part (b) has an overall complexity of 17. This indicates that the curriculum
in part (b) will be slightly more difficult to complete than the one in part (a). In particular, notice
that course ``v_1`` in part (a) has the highest individual course complexity, but the combination of
courses ``v_1`` and ``v_2`` in part (b), which both must be passed before a student can attempt course
``v_3`` in that curriculum, has a higher combined complexity.
"""
function complexity(c::Curriculum)
    course_complexity = Array{Number, 1}(undef, c.num_courses)
    curric_complexity = 0
    if !haskey(c.metrics, "delay factor")
        delay_factor(c)
    end
    if !haskey(c.metrics, "blocking factor")
        blocking_factor(c)
    end
    for v in vertices(c.graph)
        c.courses[v].metrics["complexity"] = c.courses[v].metrics["delay factor"] + c.courses[v].metrics["blocking factor"]
        if c.system_type == quarter
            c.courses[v].metrics["complexity"] = round((c.courses[v].metrics["complexity"] * 2)/3, digits=1)
        end
        course_complexity[v] = c.courses[v].metrics["complexity"]
        curric_complexity += course_complexity[v]
    end
    return c.metrics["complexity"] = curric_complexity, course_complexity
end

# Find all the longest paths in a curriculum.
"""
    longest_paths(c::Curriculum)

Finds longest paths in curriculum `c`, and returns an array of course arrays, where
each course array contains the courses in a longest path.

 # Arguments
Required:
- `c::Curriculum` : a valid curriculum.

```julia-repl
julia> paths = longest_paths(c)
```
"""
function longest_paths(c::Curriculum)
    lps = Array{Array{Course,1},1}()
    for path in longest_paths(c.graph) # longest_paths(), GraphAlgs.jl
       c_path = courses_from_vertices(c, path)
       push!(lps, c_path)
    end
    return c.metrics["longest paths"] = lps
end

# Compare the metrics associated with two curricula
# to print out the report, use: println(String(take!(report))), where report is the IOBuffer returned by this function
function compare_curricula(c1::Curriculum, c2::Curriculum)
    report = IOBuffer()
    if collect(keys(c1.metrics)) != collect(keys(c2.metrics))
        error("cannot compare curricula, they do not have the same metrics")
    end
    write(report, "Comparing: C1 = $(c1.name) and C2 = $(c2.name)\n")
    for k in keys(c1.metrics)
        write(report, " Curricular $k: ")
        if length(c1.metrics[k]) == 2 # curriculum has course-level metrics
            metric1 = c1.metrics[k][1]
            metric2 = c2.metrics[k][1]
        else
            metric1 = c1.metrics[k]
            metric2 = c2.metrics[k]
        end
        diff = c1.metrics[k][1] - c2.metrics[k][1]
        if diff > 0
            @printf(report, "C1 is %.1f units (%.0f%c) larger than C2\n", diff, 100*diff/c2.metrics[k][1], '%')
        elseif diff < 0
            @printf(report, "C1 is %.1f units (%.0f%c) smaller than C2\n", -diff, 100*(-diff)/c2.metrics[k][1], '%')
        else
            write(report, "C1 and C2 have the same curricular $k\n")
        end
        if length(c1.metrics[k]) == 2
            write(report, "  Course-level $k:\n")
            for (i, c) in enumerate([c1, c2])
                maxval = maximum(c.metrics[k][2])
                pos = [j for (j, x) in enumerate(c.metrics[k][2]) if x == maxval]
                write(report, "   Largest $k value in C$i is $maxval for course: ")
                for p in pos
                    write(report, "$(c.courses[p].name)  ")
                end
                write(report, "\n")
            end
        end
    end
    return report
end

# Create a list of courses or course names from a array of vertex IDs.
# The array returned can be (keyword arguments):
#   -course data objects : object
#   -the names of courses : name
#   -the full names of courses (prefix, number, name) : fullname
function courses_from_vertices(curriculum::Curriculum, vertices::Array{Int,1}; course::String="object")
    if course == "object"
        course_list = Course[]
    else
        course_list = String[]
    end
    for v in vertices
        c = curriculum.courses[v]
        course == "object" ? push!(course_list, c) : nothing
        course == "name" ? push!(course_list, "$(c.name)") : nothing
        course == "fullname" ? push!(course_list, "$(c.prefix) $(c.num) - $(c.name)") : nothing
    end
    return course_list
end

# Basic metrics for a currciulum.
"""
    basic_metrics(c::Curriculum)

Compute the basic metrics associated with curriculum `c`, and return an IO buffer containing these metrics.  The basic
metrics are also stored in the `metrics` dictionary associated with the curriculum.

The basic metrics computed include:

- number of credit hours : The total number of credit hours in the curriculum.
- number of courses : The total courses in the curriculum.
- blocking factor : The blocking factor of the entire curriculum, and of each course in the curriculum.
- centrality : The centrality measure associated with the entire curriculum, and of each course in the curriculum.
- delay factor : The delay factor of the entire curriculum, and of each course in the curriculum.
- curricular complexity : The curricular complexity of the entire curriculum, and of each course in the curriculum.

Complete descriptions of these metrics are provided above.

```julia-repl
julia> metrics = basic_metrics(curriculum)
julia> println(String(take!(metrics)))
julia> # The metrics are also stored in a dictonary that can be accessed as follows
julia> curriculum.metrics
```
"""
function basic_metrics(curric::Curriculum)
    buf = IOBuffer()
    complexity(curric), centrality(curric), longest_paths(curric)  # compute all curricular metrics
    max_bf = 0; max_df = 0; max_cc = 0; max_cent = 0
    max_bf_courses = Array{Course,1}(); max_df_courses = Array{Course,1}(); max_cc_courses = Array{Course,1}(); max_cent_courses = Array{Course,1}()
    for c in curric.courses
        if c.metrics["blocking factor"] == max_bf
            push!(max_bf_courses, c)
        elseif  c.metrics["blocking factor"] > max_bf
            max_bf = c.metrics["blocking factor"]
            max_bf_courses = Array{Course,1}()
            push!(max_bf_courses, c)
        end
        if c.metrics["delay factor"] == max_df
            push!(max_df_courses, c)
        elseif  c.metrics["delay factor"] > max_df
            max_df = c.metrics["delay factor"]
            max_df_courses = Array{Course,1}()
            push!(max_df_courses, c)
        end
        if c.metrics["complexity"] == max_cc
            push!(max_cc_courses, c)
        elseif  c.metrics["complexity"] > max_cc
            max_cc = c.metrics["complexity"]
            max_cc_courses = Array{Course,1}()
            push!(max_cc_courses, c)
        end
        if c.metrics["centrality"] == max_cent
            push!(max_cent_courses, c)
        elseif  c.metrics["centrality"] > max_cent
            max_cent = c.metrics["centrality"]
            max_cent_courses = Array{Course,1}()
            push!(max_cent_courses, c)
        end
        curric.metrics["max. blocking factor"] = max_bf
        curric.metrics["max. blocking factor courses"] = max_bf_courses
        curric.metrics["max. centrality"] = max_cent
        curric.metrics["max. centrality courses"] = max_cent_courses
        curric.metrics["max. delay factor"] = max_df
        curric.metrics["max. delay factor courses"] = max_df_courses
        curric.metrics["max. complexity"] = max_cc
        curric.metrics["max. complexity courses"] = max_cc_courses
    end
    # write metrics to IO buffer
    write(buf, "\n$(curric.institution) ")
    write(buf, "\nCurriculum: $(curric.name)\n")
    write(buf, "  credit hours = $(curric.credit_hours)\n")
    write(buf, "  number of courses = $(curric.num_courses)")
    write(buf, "\n  Blocking Factor --\n")
    write(buf, "    entire curriculum = $(curric.metrics["blocking factor"][1])\n")
    write(buf, "    max. value = $(max_bf), ")
    write(buf, "for course(s): ")
    write_course_names(buf, max_bf_courses)
    write(buf, "\n  Centrality --\n")
    write(buf, "    entire curriculum = $(curric.metrics["centrality"][1])\n")
    write(buf, "    max. value = $(max_cent), ")
    write(buf, "for course(s): ")
    write_course_names(buf, max_cent_courses)
    write(buf, "\n  Delay Factor --\n")
    write(buf, "    entire curriculum = $(curric.metrics["delay factor"][1])\n")
    write(buf, "    max. value = $(max_df), ")
    write(buf, "for course(s): ")
    write_course_names(buf, max_df_courses)
    write(buf, "\n  Complexity --\n")
    write(buf, "    entire curriculum = $(curric.metrics["complexity"][1])\n")
    write(buf, "    max. value = $(max_cc), ")
    write(buf, "for course(s): ")
    write_course_names(buf, max_cc_courses)
    write(buf, "\n  Longest Path(s) --\n")
    write(buf, "    length = $(length(curric.metrics["longest paths"][1])), number of paths = $(length(curric.metrics["longest paths"]))\n    path(s):\n")
    for (i, path) in enumerate(curric.metrics["longest paths"])
        write(buf, "    path $i = ")
        write_course_names(buf, path, separator=" -> ")
        write(buf, "\n")
    end
    return buf
end

function basic_statistics(curricula::Array{Curriculum,1}, metric_name::AbstractString)
    buf = IOBuffer()
    # set initial values used to find min and max metric values
    total_metric = 0; STD_metric = 0
    if haskey(curricula[1].metrics, metric_name)
        if typeof(curricula[1].metrics[metric_name]) == Float64
            max_metric = curricula[1].metrics[metric_name]; min_metric = curricula[1].metrics[metric_name];
        elseif typeof(curricula[1].metrics[metric_name]) == Tuple{Float64,Array{Number,1}}
            max_metric = curricula[1].metrics[metric_name][1]; min_metric = curricula[1].metrics[metric_name][1];  # metric where total curricular metric as well as course-level metrics are stored in an array
        end
    end
    for c in curricula
        if !haskey(c.metrics, metric_name)
            error("metric $metric_name does not exist in curriculum $(c.name)")
        end
        basic_metrics(c)
        if typeof(c.metrics[metric_name]) == Float64
            value = c.metrics[metric_name]
        elseif typeof(c.metrics[metric_name]) == Tuple{Float64,Array{Number,1}}
            value = c.metrics[metric_name][1]  # metric where total curricular metric as well as course-level metrics are stored in an array
        end
        total_metric += value
        value > max_metric ? max_metric = value : nothing
        value < min_metric ? min_metric = value : nothing
    end
    avg_metric = total_metric / length(curricula)
    for c in curricula
        if typeof(c.metrics[metric_name]) == Float64
            value = c.metrics[metric_name]
        elseif typeof(c.metrics[metric_name]) == Tuple{Float64,Array{Number,1}}
            value = c.metrics[metric_name][1]  # metric where total curricular metric as well as course-level metrics are stored in an array
        end
        STD_metric = (value - avg_metric)^2
    end
    STD_metric = sqrt(STD_metric / length(curricula))
    write(buf, "\n Metric -- $metric_name")
    write(buf, "\n  Number of curricula = $(length(curricula))")
    write(buf, "\n  Mean = $avg_metric")
    write(buf, "\n  STD = $STD_metric")
    write(buf, "\n  Max. = $max_metric")
    write(buf, "\n  Min. = $min_metric")
    return(buf)
end

function write_course_names(buf::IOBuffer, courses::Array{Course,1}; separator::String=", ")
    if length(courses) == 1
      write_course_name(buf, courses[1])
    else
      for c in courses[1:end-1]
        write_course_name(buf, c)
        write(buf, separator)
      end
        write_course_name(buf, courses[end])
    end
end

function write_course_name(buf::IOBuffer, c::Course)
    !isempty(c.prefix) ? write(buf, "$(c.prefix) ") : nothing
    !isempty(c.num) ? write(buf, "$(c.num) - ") : nothing
    write(buf, "$(c.name)")  # name is a required item
end

"""
    similarity(c1, c2; strict)

Compute how similar curriculum `c1` is to curriculum `c2`.  The similarity metric is computed by comparing how many courses in
`c1` are also in `c2`, divided by the total number of courses in `c2`.  Thus, for two curricula, this metric is not symmetric. A
similarity value of `1` indicates that `c1` and `c2` are identical, whil a value of `0` means that none of the courses in `c1`
are in `c2`.

# Arguments
Required:
- `c1::Curriculum` : the target curriculum.
- `c2::Curriculum` : the curriculum serving as the basis for comparison.

Keyword:
- `strict::Bool` : if true (default), two courses are considered the same if every field in the two courses are the same; if false,
two courses are conisdred the same if they have the same course name, or if they have the same course prefix and number.

```julia-repl
julia> similarity(curric1, curric2)
```
"""
function similarity(c1::Curriculum, c2::Curriculum; strict::Bool=true)
    if c2.num_courses == 0
        error("Curriculum $(c2.name) does not have any courses, similarity cannot be computed")
    end
    if (c1 == c2) return 1 end
    matches = 0
    if strict == true
        for course in c1.courses
            if course in c2.courses
                matches += 1
            end
        end
    else  # strict == false
        for course in c1.courses
            for basis_course in c2.courses
                if (course.name != "" && basis_course.name == course.name) || (course.prefix != "" && basis_course.prefix == course.prefix && course.num != "" && basis_course.num == course.num)
                    matches += 1
                    break # only match once
                end
            end
        end
    end
    return matches/c2.num_courses
end

"""
    merge_curricula(c1, c2; match_criteria)

Merge the two curricula `c1` and `c2` supplied as input into a single curriculum based on the match criteria applied
to the courses in the two curricula.  All courses in curriculum `c1` will appear in the merged curriculum.  If a course in
curriculum `c2` matches a course in curriculum `c1`, that course serves as a matched course in the merged curriculum.
If there is no match for a course in curriculum `c2` to the set of courses in curriculum `c1`, course `c2` is added
to the set of courses in the merged curriculum.

# Arguments
Required:
- `c1::Curriculum` : first curriculum.
- `c2::Curriculum` : second curriculum.

Optional:
- `match_criteria::Array{String}` : list of course items that must match, if no match critera are supplied, the
courses must be identical (at the level of memory allocation). Allowable match criteria include:
    - `prefix` : the course prefixes must be identical.
    - `num` : the course numbers must be indentical.
    - `name` : the course names must be identical.
    - `canonical name` : the course canonical names must be identical.
    - `credit hours` : the course credit hours must be indentical.

"""
function merge_curricula(name::AbstractString, c1::Curriculum, c2::Curriculum, match_criteria::Array{String}=Array{String,1}();
           learning_outcomes::Array{LearningOutcome}=Array{LearningOutcome,1}(), degree_type::Degree=BS, system_type::System=semester,
           institution::AbstractString="", CIP::AbstractString="")
    merged_courses = deepcopy(c1.courses)
    extra_courses = Array{Course,1}()  # courses in c2 but not in c1
    new_courses = Array{Course,1}()
    for course in c2.courses
        matched = false
        for target_course in c1.courses
            if match(course, target_course, match_criteria) == true
               matched = true
               skip
            end
        end
        !matched ? push!(extra_courses, course) : nothing
    end
    # patch-up requisites of extra_courses, using course ids form c1 where appropriate
    for c in extra_courses
        # for each extra course create an indentical coures, but with a new course id
        push!(new_courses, Course(c.name, c.credit_hours; prefix=c.prefix, learning_outcomes=c.learning_outcomes,
               num=c.num, institution=c.institution, canonical_name=c.canonical_name))
    end
    for (j,c) in enumerate(extra_courses)
    #    print("\n $(c.name): ")
    #    print("total requisistes = $(length(c.requisites)),")
        for req in keys(c.requisites)
    #        print(" requisite id: $(req) ")
            req_course = course_from_id(c2, req)
            if find_match(req_course, merged_courses, match_criteria) != nothing
                # requisite already exists in c1
    #            print(" match in c1 - $(course_from_id(c1, req).name) ")
                add_requisite!(req_course, new_courses[j], c.requisites[req])
            elseif find_match(req_course, extra_courses, match_criteria) != nothing
                # requisite is not in c1, but it's in c2 -- use the id of the new course created for it
    #            print(" match in extra courses, ")
                i = findfirst(x->x==req_course, extra_courses)
    #            print(" index of match = $i ")
                add_requisite!(new_courses[i], new_courses[j], c.requisites[req])
            else # requisite is neither in c1 or 2 -- this shouldn't happen => error
                error("requisite error on course: $(c.name)")
            end
        end
    end
    merged_courses = [merged_courses; new_courses]
    merged_curric = Curriculum(name, merged_courses, learning_outcomes=learning_outcomes, degree_type=degree_type, institution=institution, CIP=CIP)
    return merged_curric
end

function match(course1::Course, course2::Course, match_criteria::Array{String}=Array{String,1}())
    is_matched = false
    if length(match_criteria) == 0
        return (course1 == course2)
    else
        for str in match_criteria
            if !(str in ["prefix", "num", "name", "canonical name", "credit hours"])
                error("invalid match criteria: $str")
            elseif str == "prefix"
                course1.prefix == course2.prefix ? is_matched = true : is_matched = false
            elseif str == "num"
                course1.num == course2.num ? is_matched = true : is_matched = false
            elseif str == "name"
                course1.name == course2.name ? is_matched = true : is_matched = false
            elseif str == "canonical name"
                course1.canonical_name == course2.canonical_name ? is_matched = true : is_matched = false
            elseif str == "credit hours"
                course1.credit_hours == course2.credit_hours ? is_matched = true : is_matched = false
            end
        end
    end
    return is_matched
end

function find_match(course::Course, course_set::Array{Course}, match_criteria::Array{String}=Array{String,1}())
    for c in course_set
        if match(course, c, match_criteria)
            return course
        end
    end
    return nothing
end

function homology(curricula::Array{Curriculum,1}; strict::Bool=false)
    similarity_matrix = Matrix{Float64}(I, length(curricula), length(curricula))
    for i = 1:length(curricula)
        for j = 1:length(curricula)
            similarity_matrix[i,j] = similarity(curricula[i], curricula[j], strict=strict)
            similarity_matrix[j,i] = similarity(curricula[j], curricula[i], strict=strict)
        end
    end
    return similarity_matrix
end

"""
    dead_ends(curric, prefixes)

Finds all courses in curriculum `curric` that appear at the end of a path (i.e., sink vertices), and returns those courses that
do not have one of the course prefixes listed in the `prefixes` array.  If a course does not have a prefix, it is excluded from
the analysis.

# Arguments
- `c::Curriculum` : the target curriculum.
- `prefixes::Array{String,1}` : an array of course prefix strings.

For instance, the following will find all courses in `curric` that appear at the end of any course path in the curriculum,
and do *not* have `BIO` as a prefix.  One might consider these courses "dead ends," as their course outcomes are not used by any
major-specific course, i.e., by any course with the prefix `BIO`.

```julia-repl
julia> dead_ends(curric, ["BIO"])
```
"""
function dead_ends(curric::Curriculum, prefixes::Array{String,1})
    dead_end_courses = Array{Course,1}()
    paths = all_paths(curric.graph)
    for p in paths
        course = course_from_vertex(curric, p[end])
        if course.prefix == ""
            continue
        end
        if !(course.prefix in prefixes)
            if !(course in dead_end_courses)
                push!(dead_end_courses, course)
            end
        end
    end
    if haskey(curric.metrics, "dead end")
        if !haskey(curric.metrics["dead end"], prefixes)
            push!(curric.metrics["dead end"], prefixes => dead_end_courses)
        end
    else
        curric.metrics["dead end"] = Dict(prefixes => dead_end_courses)
    end
    return (prefixes, dead_end_courses)
end

end # module
