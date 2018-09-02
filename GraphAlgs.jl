
using LightGraphs

# Depth-first search, returns edge classification using EdgeClass
function dfs(g::AbstractGraph{T}) where T
    time = 0
    # discover and finish times
    d = zeros(Int, nv(g))
    f = zeros(Int, nv(g))
    edge_type = Dict{Edge,EdgeClass}()
    for s in vertices(g)
        if d[s] == 0  # undiscovered
            # nested function definition, shares variable space w/ outer function
            function dfs_visit(s)
                d[s] = time += 1  # discovered
                for n in
                    neighbors(g, s)
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
            end # end dfs_visit nested function
            dfs_visit(s)  # call the nested function
        end
    end
    return edge_type
end # end dfs

# transpose of DAG
function gad(g::AbstractGraph{T}) where T
    @assert typeof(g) == SimpleDiGraph{T}
    return SimpleDiGraph(transpose(adjacency_matrix(g)))
end

# The set of all vertices in the graph reachable from vertex s
function reachable_from(g::AbstractGraph{T}, s::Int, vlist::Array=Array{Int64,1}()) where T
    for v in neighbors(g, s)
        push!(vlist, v)
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

# The longest path from vertx v to any other vertex in a DAG G
# Note: in a DAG, longest path in G = shortest path in -G
function longest_path(g::AbstractGraph{T}, s::Int) where T
    if is_cyclic(g)
        error("longest_path(): input graph must be a DAG")
    end
    lp = Array{Edge}[]
    max = 0
    for v in vertices(g)
        path = a_star(g,s,v,-adjacency_matrix(g))  # shortest path from s to v in -G
        if length(path) > max
            lp = path
            max = length(path)
        end
    end
    return lp
end
