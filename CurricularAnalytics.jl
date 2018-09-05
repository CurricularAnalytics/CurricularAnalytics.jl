#module CurricularAnalytics

    # Dependencies
    using LightGraphs, SimpleWeightedGraphs, JSON

    # Imports
    include("DataTypes.jl")
    include("GraphAlgs.jl")

    # Exports
#    export Degree, System, Requisite, EdgeClass, Course, add_requisite!, Curriculum, total_credits, create_graph!,
#            requisite_type, Term, DegreePlan, dfs, longest_path, isvalid_curriculum, blocking_factor, delay_factor,
#            complexity, isvalid_degree_plan, print_plan
    # end Exports


    # Report if the input graph has cycles or forward edges
    function isvalid_curriculum(c::Curriculum)
        g = c.graph
        validity = true
        error_msg = IOBuffer()
        cycles = simplecycles(g)
        if size(cycles,1) != 0
            validity = false
            print(error_msg, "\nCurriculum contains the following prerequisite cycles:\n")
            for c in cycles
                print(error_msg, "  $c\n")
            end
        end
        n=0
        edge_type = dfs(g)
        for e in edges(g)
            if edge_type[e] == forward_edge
                if n == 0
                  print(error_msg, "\nCurriculum contains the following extraneous prerequisites:\n")
                  n += 1
                end
                print(error_msg, "  $(e)\n")
            end
        end
        return validity, String(take!(error_msg))
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
    function centrality(c::Curriculum, course::Int)
        cent = 0; g = c.graph
        if isempty(inneighbors(g, course)) || isempty(outneighbors(g, course))
            return cent # if course is a sink or source, centrality = 0
        else
            for v in collect(Iterators.flatten((1:course-1,course+1:c.num_courses)))  # exclude course from the iterator
                for path in enumerate_paths(dijkstra_shortest_paths(g, v, -weights(g), allpaths=true))
                    if (length(path) > 2) && (isempty(inneighbors(g, c.courses[path[1]].vertex_id))) && (path[1] != course) && (isempty(outneighbors(g, c.courses[path[end]].vertex_id))) && (path[end] != course)
                        cent += length(path)
                    end
                end
            end
        end
        return c.courses[course].metrics["centrality"] = cent
    end

    # Compute the total centrality of all courses in a curriculum
    function centrality(c::Curriculum)
        cent = 0
        for v in vertices(c.graph)
            cent += centrality(c, v)
        end
        return c.metrics["centrality"] = cent
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
