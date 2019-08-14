
# File: GraphAlgs.jl

# Depth-first search, returns edge classification using EdgeClass, as well as the discovery and finish time for each vertex.
function dfs(g::AbstractGraph{T}) where T
    time = 0
    # discover and finish times
    d = zeros(Int, nv(g))
    f = zeros(Int, nv(g))
    edge_type = Dict{Edge,EdgeClass}()
    for s in vertices(g)
        if d[s] == 0  # undiscovered
            # a closure, shares variable space w/ outer function
            function dfs_visit(s)
                d[s] = time += 1  # discovered
                for n in neighbors(g, s)
                    if d[n] == 0 # encounted a undiscovered vertex
                        edge_type[Edge(s,n)] = tree_edge
                        dfs_visit(n)
                    elseif f[n] == 0 # encountered a discovered but unfinished vertex
                        edge_type[Edge(s,n)] = back_edge
                    else  # encountered a finished vertex
                        if d[s] < d[n]
                            edge_type[Edge(s,n)] = forward_edge
                        else # d[s] > d[n]
                            edge_type[Edge(s,n)] = cross_edge
                        end
                    end
                end
                f[s] = time += 1  # finished
            end # end closure
            dfs_visit(s)  # call the closure
        end
    end
    return edge_type, d, f
end # end dfs

# In a DFS of a DAG, sorting the vertices according to their finish times in the DFS will yeild a topological sorting of the 
# DAG vertices. 
 """
    topological_sort(g; <keyword arguments>)

Perform a topoloical sort on graph `g`, returning the weakly connected components of the graph, each in topological sort order.
If the `sort` keyword agrument is supplied, the components will be sorted according to their size, in either ascending or 
descending order.  If two or more components have the same size, the one with the smallest vertex ID in the first position of the 
topological sort will appear first.
```

# Arguments
Required:
- `g::AbstractGraph` : input graph.
Keyword:
- `sort::String` : sort weakly connected components according to their size, allowable 
strings: `ascending`, `descending`.
"""
function topological_sort(g::AbstractGraph{T}; sort::String="") where T
    edges_type, d, f = dfs(g)
    topo_order = sortperm(f, rev=true)
    wcc = weakly_connected_components(g)
    if sort == "descending"
        sort!(wcc, lt = (x,y) -> size(x) != size(y) ? size(x) > size(y) : x[1] < y[1]) # order components by size, if same size, by lower index
    elseif sort == "ascending"
        sort!(wcc, lt = (x,y) -> size(x) != size(y) ? size(x) < size(y) : x[1] < y[1]) # order components by size, if same size, by lower index
    end
    reorder = [] 
    for component in wcc
        sort!(component, lt = (x,y) -> indexin(x, topo_order)[1] < indexin(y, topo_order)[1]) # topological sort within each component 
        for i in component
            push!(reorder, i) # add verteix indicies to the end of the reorder array
        end
    end
    return wcc
end

# transpose of DAG
"""
    gad(g)

Returns the transpose of directed acyclic graph (DAG) `g`, i.e., a DAG identical to `g`, except the direction
of all edges is reversed.  If `g` is not a DAG, and error is thrown.
```

# Arguments
Required:
- `g::SimpleDiGraph` : input graph.
"""
function gad(g::AbstractGraph{T}) where T
    @assert typeof(g) == SimpleDiGraph{T}
    return SimpleDiGraph(transpose(adjacency_matrix(g)))
end

# The set of all vertices in the graph reachable from vertex s
function reachable_from(g::AbstractGraph{T}, s::Int, vlist::Array=Array{Int64,1}()) where T
    for v in neighbors(g, s)
        if findfirst(isequal(v), vlist) == nothing  # v is not in vlist
            push!(vlist, v)
        end
        reachable_from(g, v, vlist)
    end
    return vlist
end

# The subgraph induced by vertex s and the vertices reachable from vertex s
#
# usage:
# julia> sg_data = reachable_from_subgraph(g,v)
#   Returns the subgraph of `g` induced by the vertices reachable from `v`
#   along with a vector mapping the new vertices to the old ones.
#   (the  vertex `i` in the subgraph corresponds to the vertex `vmap[i]` in `g`.)
#
# julia> sg, vmap = reachable_from_subgraph(g,v)
#   Returns the subgraph of `g` induced by the vertices reachable from `v`
#   as a LightGraph object stored in sg
function reachable_from_subgraph(g::AbstractGraph{T}, s::Int) where T
    vertices = reachable_from(g, s)
    push!(vertices, s)  # add the source vertex to the reachable set
        induced_subgraph(g, vertices)
#    end
end

# The set of all vertices in the graph that can reach vertex s
function reachable_to(g::AbstractGraph{T}, s::Int) where T
   reachable_from(gad(g), s)  # vertices reachable from s in the transpose graph
end

function reachable_to_subgraph(g::AbstractGraph{T}, s::Int) where T
    vertices = reachable_to(g, s)
    push!(vertices, s)  # add the source vertex to the reachable set
    induced_subgraph(g, vertices)
end

# The set of all vertices reachable to and reachable from vertex s
function reach(g::AbstractGraph{T}, s::Int) where T
    union(reachable_to(g,s),reachable_from(g,s))
end

function reach_subgraph(g::AbstractGraph{T}, s::Int) where T
    vertices = reach(g, s)
    push!(vertices, s)  # add the source vertex to the reachable set
    induced_subgraph(g, vertices)
end

# The longest path from vertx s to any other vertex in a DAG G (not necessarily unique,
# i.e., there can be more than one longest path between two vertices)
# Note: in a DAG G, longest paths in G = shortest paths in -G
function longest_path(g::AbstractGraph{T}, s::Int) where T
    if is_cyclic(g)
        error("longest_path(): input graph has cycles")
    end
    lp = Array{Edge}[]
    max = 0
    # shortest path from s to all vertices in -G
    for path in enumerate_paths(dijkstra_shortest_paths(g, s, -weights(g), allpaths=true))
        if length(path) > max
            lp = path
            max = length(path)
        end
    end
    return lp
end

# Enumerate all unique long paths in a DAG G, where a long path must include a
# source vertex (in-degree zero) and a different sink vertex (out-degree zero),
# i.e., must be a path containing at least two vertices
function long_paths(g::AbstractGraph{T}) where T
    if is_cyclic(g)
        error("long_paths(): input graph has cycles")
    end
    que = Queue{Array}()
    paths = Array[]
    sinks = Int[]
    for v in vertices(g)
        if (length(outneighbors(g,v)) == 0) && (length(inneighbors(g,v)) > 0) # consider only sink vertices with an in-degree
            push!(sinks, v)
        end
    end
    for v in sinks
        enqueue!(que, [v])
        while !isempty(que) # work backwards from sink v to all sources reachable to v in BFS fashion
            x = dequeue!(que)
            for (i, u) in enumerate(inneighbors(g, x[1]))
                if i == 1
                    insert!(x, 1, u)  # prepend vertx u to array x, first neighbor
                else
                    x[1] = u # put new neighbor at the head of array, replacing an in-neighbor
                end
                if length(inneighbors(g, u)) == 0  # reached a source vertex, done with path
                    push!(paths, x)
                else
                    enqueue!(que, copy(x))
                end
            end
        end
    end
    return paths
end
