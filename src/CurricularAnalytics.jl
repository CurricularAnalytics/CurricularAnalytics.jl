module CurricularAnalytics

# Dependencies
using LightGraphs
using DataStructures
using Printf

include("DataTypes.jl")
include("GraphAlgs.jl")
include("JsonHandler.jl")
include("Visualization.jl")
include("Optimization.jl")

export Degree, AA, AS, AAS, BA, BS, System, semester, quarter, Requisite, pre, co, strict_co,
        EdgeClass, LearningOutcome, Course, add_requisite!, Curriculum, total_credits,
        create_graph!, requisite_type, Term, DegreePlan, dfs, longest_path, long_paths,
        isvalid_curriculum, extraneous_requisites, blocking_factor, delay_factor, centrality,
        complexity, compare_curricula, isvalid_degree_plan, print_plan, export_degree_plan, visualize,
        import_degree_plan

# check if a curriculum graph has requisite cycles or extraneous requsities
# print error_msg using println(String(take!(error_msg))), where error_msg is the buffer returned by this function
function isvalid_curriculum(c::Curriculum, error_msg::IOBuffer=IOBuffer())
    g = c.graph
    validity = true
    # first check for cycles
    cycles = simplecycles(g)
    if size(cycles,1) != 0
        validity = false
        write(error_msg, "\nCurriculum $(c.name) contains the following requisite cycles:\n")
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
    else # no cycles, can now check for extraneous requisites
        extran_errors = IOBuffer()
        if extraneous_requisites(c, extran_errors)
            validity = false
            write(error_msg, "\nCurriculum $(c.name) contains the following extraneous requisites:\n")
            write(error_msg, String(take!(extran_errors)))
        end
    end
    return validity
end

function extraneous_requisites(c::Curriculum, error_msg::IOBuffer)
    if is_cyclic(c.graph)
        error("extraneous requisities cannot be found in a curriculum graph that contains cycles")
    end
    g = c.graph
    que = Queue{Int}()
    components = weakly_connected_components(g)
    extraneous = false
    for wcc in components
        if length(wcc) > 1  # only consider curriculum graph components with more than one vertex
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
                            # TODO: If this edge is a co-requistie it is an error, as it would be impossible to satsify.
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
                                write(error_msg, "Course $(c.courses[v].name) has redundant requisite: $(c.courses[u].name)")
                                extraneous = true
                            end
                        end
                    end
                end
            end
        end
    end
    return extraneous
end

# Compute the blocking factor of a course
function blocking_factor(c::Curriculum, course::Int)
    b = length(reachable_from(c.graph, course))
    return c.courses[course].metrics["blocking factor"] = b
end

# Compute the blocking factor of a curriculum
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
function delay_factor(c::Curriculum, course::Int)
    if !haskey(c.courses[course].metrics, "delay factor")
        delay_factor(c)
    end
    return c.courses[course].metrics["delay factor"]
end

# Compute the delay factor of a curriculum
function delay_factor(c::Curriculum)
    g = c.graph
    df = ones(c.num_courses)
    for v in vertices(g)
        if length(neighbors(g, v)) != 0   # not a standalone course
            # enumerate all of the longest paths from v (these are shortest paths in -G)
            for path in enumerate_paths(dijkstra_shortest_paths(g, v, -weights(g), allpaths=true))
                for vtx in path
                    path_length = length(path)  # path_length in terms of # of nodes, not edges
                    if path_length > df[vtx]
                        df[vtx] = path_length
                    end
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
function centrality(c::Curriculum, course::Int)
    cent = 0; g = c.graph
    for path in long_paths(g)  # all long paths in g
        # conditions: path length is greater than 2, target course must be in the path, the target vertex cannot be the first or last vertex in the path
        if (in(course,path) && length(path) > 2 && path[1] != course && path[end] != course)
            cent += length(path)
        end
    end
    return c.courses[course].metrics["centrality"] = cent
end

# Compute the total centrality of all courses in a curriculum
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
function complexity(c::Curriculum, course::Int)
    if !haskey(c.courses[course].metrics, "complexity")
        complexity(c)
    end
    return c.courses[course].metrics["complexity"]
end

# Compute the complexity of a curriculum
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
        course_complexity[v] = c.courses[v].metrics["complexity"]
        curric_complexity += course_complexity[v]
    end
    return c.metrics["complexity"] = curric_complexity, course_complexity
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

include("./DegreePlanAnalytics.jl")
include("./Visualization.jl")

end # module
