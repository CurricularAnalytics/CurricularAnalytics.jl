#module CurricularAnalytics

    # Dependencies
    using LightGraphs, SimpleWeightedGraphs, JSON, DataStructures

    # Imports
    include("DataTypes.jl")
    include("GraphAlgs.jl")

    # Exports
#    export Degree, System, Requisite, EdgeClass, Course, add_requisite!, Curriculum, total_credits, create_graph!,
#            requisite_type, Term, DegreePlan, dfs, longest_path, isvalid_curriculum, blocking_factor, delay_factor,
#            complexity, isvalid_degree_plan, print_plan
    # end Exports


    # check if a curriculum graph has requisite cycles or extraneous requsities
    # print error_msg using String(take!(error_msg))
    function isvalid_curriculum(c::Curriculum, error_msg::IOBuffer=IOBuffer())
        g = c.graph
        validity = true
        # first check for cycles
        cycles = simplecycles(g)
        if size(cycles,1) != 0
            validity = false
            print(error_msg, "\nCurriculum $(c.name) contains the following requisite cycles:\n")
            for cyc in cycles
                print(error_msg, "(")
                for (i,v) in enumerate(cyc)
                    if i != length(cyc)
                        print(error_msg, "$(c.courses[v].name), ")
                    else
                        print(error_msg, "$(c.courses[v].name))\n")
                    end
                end
            end
        else # no cycles, can now check for extraneous requisites
            extran_errors = IOBuffer()
            if extraneous_requisites(c, extran_errors)
                validity = false
                print(error_msg, "\nCurriculum $(c.name) contains the following extraneous requisites:\n")
                print(error_msg, String(extran_errors))
            end
        end
        return validity
    end

    function extraneous_requisites(c::Curriculum, error_msg::IOBuffer)
        if is_cyclic(c.graph)
            error("extraneous requisities cannot be found in a curriculum graph that contains cycles")
        end
        g = c.graph
        que = Queue(Int)
        components = weakly_connected_components(g)
        extraneous = false
        for wcc in components
            if length(wcc) > 1  # only conider curriculum graph components with more than one vertex
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
                            if has_edge(g, u, v)  # possible reducdant requsisite
                                # Todo: If this edge is a co-requistie it is an error, as it would be impossible to satsify.
                                #       This needs to be checked here.
                                remove = true
                                for n in nb  # check for co- or strict_co requisites
                                    if has_path(c.graph, n, v) # is there a path from n to v?
                                        req_type = c.courses[n].requisites[c.courses[u]] # the requisite relationship between u and n
                                        if (req_type == co) || (req_type == strict_co)  # is u a co or strict_co requisite for n?
                                            remove = false # a co or strict_co relationshipo is involved, must keep (u, v)
                                        end
                                    end
                                end
                                if remove == true
                                    print(error_msg, "Course $(c.courses[v].name) has redundant requisite: $(c.courses[u].name)")
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
    function blocking_factor(c::Curriculum, course::Int, b=-1)
        b = length(reachable_from(c.graph,course))
        return c.courses[course].metrics["blocking factor"] = b
    end

    # Compute the blocking factor of a curriculum
    function blocking_factor(c::Curriculum)
        b = 0
        for v in vertices(c.graph)
            b += blocking_factor(c, v)
        end
        return c.metrics["blocking factor"] = b
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
        c.metrics["delay factor"] = 0
        for v in vertices(g)
            c.courses[v].metrics["delay factor"] = df[v]
            c.metrics["delay factor"] += c.courses[v].metrics["delay factor"]
        end
        return c.metrics["delay factor"], df
    end

    # Compute the centrality of a course
    function centrality_old(c::Curriculum, course::Int)
        cent = 0; g = c.graph
        if isempty(inneighbors(g, course)) || isempty(outneighbors(g, course))
            return cent # if course is a sink or source, centrality = 0
        else
            for v in collect(Iterators.flatten((1:course-1,course+1:c.num_courses)))  # exclude course from the iterator
                for path in enumerate_paths(dijkstra_shortest_paths(g, v, -weights(g), allpaths=true))  # all long paths starting with v
                    # conditions: path length is greater than 2, target course must be in the pather, the first vertex in the path must be a source, the last vertex in the path must be a sink, the target vertex cannot be the first or last vertex in the path
                    # only vertices satisfying these conditions can have a non-zero centrality measure
                    if (length(path) > 2) && (in(course,path)) && (isempty(inneighbors(g, c.courses[path[1]].vertex_id))) && (isempty(outneighbors(g, c.courses[path[end]].vertex_id))) && (path[1] != course) &&  (path[end] != course)
                        cent += length(path)
                    end
                end
            end
        end
        return c.courses[course].metrics["centrality"] = cent
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
        cf = Array{Int,1}(c.num_courses)
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
        course_complexity = Array{Number}(c.num_courses)
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
        c.metrics["complexity"] = curric_complexity
        return curric_complexity
    end


#end
