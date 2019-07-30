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

include("DataTypes.jl")
include("DegreePlanCreation.jl")
include("GraphAlgs.jl")
include("DegreePlanAnalytics.jl")
include("CSVUtilities.jl")
include("DataHandler.jl")
include("Visualization.jl")

export Degree, AA, AS, AAS, BA, BS, System, semester, quarter, Requisite, pre, co, strict_co,
        EdgeClass, LearningOutcome, Course, add_requisite!, delete_requisite!, Curriculum, 
        total_credits, requisite_type, Term, DegreePlan, dfs, longest_path, long_paths,
        isvalid_curriculum, extraneous_requisites, blocking_factor, delay_factor, centrality,
        complexity, compare_curricula, isvalid_degree_plan, print_plan, visualize, basic_metrics,
        read_csv, create_degree_plan, bin_packing, bin_packing2, find_min_terms, add_lo_requisite!, 
        update_plan, write_csv, find_min_terms, balance_terms, balance_terms_opt, find_min_terms_opt, 
        read_Opt_Config, optimize_plan, json_to_julia, julia_to_json, init_optimization

function init_opt()
    println("In order to use the optimization functions in this toolbox you must first install the Gurobi Optimizer,\n  
             please see: https://www.gurobi.com/downloads/gurobi-optimizer/. \n 
             Free acacdemic licenses are available: https://www.gurobi.com/downloads/end-user-license-agreement-academic/.\n")
    include("Optimization.jl")
end

# Check if a curriculum graph has requisite cycles or extraneous requsities.
"""
    isvalid_curriculum(c::Curriculum, errors::IOBuffer)

Tests whether or not the curriculum graph ``G_c`` associated with curriculum `c` is valid.  Returns 
a boolean value, with `true` indicating the curriculum is valid, and `false` indicating it 
is not.

If ``G_c`` is not valid, the reason(s) why are written to the `errors` buffer. To view these 
reasons, use:

```julia-repl
julia> errors = IOBuffer()
julia> isvalid_curriculum(c, errors)
julia> println(String(take!(errors)))
```

There are two reasons why a curriculum graph might not be valid:
- Cycles : If a curriculum graph contains a directed cycle, it is not possible to complete the curriculum.
- Extraneous Requisites : These are redundant requisites that introduce spurious complexity.
  If a curriculum has the prerequisite relationships \$c_1 \\rightarrow c_2 \\rightarrow c_3\$ 
  and \$c_1 \\rightarrow c_3\$, and \$c_1\$ and \$c_2\$ are *not* co-requisites, then \$c_1 
  \\rightarrow c_3\$ is redundant and therefore extraneous.   
"""
function isvalid_curriculum(c::Curriculum, error_msg::IOBuffer=IOBuffer())
    g = c.graph
    validity = true
    # first check for cycles
    cycles = simplecycles(g)
    if size(cycles,1) != 0
        validity = false
        write(error_msg, "\nCurriculum \'$(c.name)\' has requisite cycles:\n")
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
            write(error_msg, "\nCurriculum \'$(c.name)\' has extraneous requisites:\n")
            write(error_msg, String(take!(extran_errors)))
        end
    end
    return validity
end

function extraneous_requisites(c::Curriculum, error_msg::IOBuffer)
    if is_cyclic(c.graph) # error condition should no occur, as cycles are checked in isvalid_curriculum()
        error("\nExtraneous requisities are due to cycles in the curriculum graph")
    end
    g = c.graph
    que = Queue{Int}()
    components = weakly_connected_components(g)
    extraneous = false
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
                                write(error_msg, "-$(c.courses[v].name) has redundant requisite $(c.courses[u].name)\n")
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
        if length(neighbors(g, v)) != 0   # not a standalone course
            # enumerate all of the longest paths from v (these are shortest paths in -G)
            for path in enumerate_paths(dijkstra_shortest_paths(g, v, -weights(g), allpaths=true))
                for vtx in path
                    path_length = length(path)  # path_length in terms of # of vertices, not edges
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
    for path in long_paths(g)  # all long paths in g
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

end # module