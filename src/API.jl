# https://discourse.julialang.org/t/write-a-rest-interface-like-flask/18538/16

# Bukdu v0.4.1
using Bukdu

struct RESTController <: ApplicationController
    conn::Conn
end

# function create(c::RESTController)
#     @info :payload (c.params.message, c.params.x, c.params.y)
#     render(JSON, "OK")
# end

# routes() do
#     post("/messages", RESTController, create)
#     plug(Plug.Parsers, parsers=[:json])
# end

function validate(c::RESTController)
    @info :PAYLOAD (c.params.curriculum)
    @info "Validating recieved degree plan..."
    degreeplan = json_to_julia(c.params.curriculum)
    result = isvalid_degree_plan(degreeplan)
    if(result)
        @info "Curriculum is valid."
    else
        @info "Curriculum is invalid"
    end
    render(JSON, julia_to_json(degreeplan))
end

function calculate_metrics(c::RESTController)
    @info "Calculating degree plan metrics..."
    degreeplan = json_to_julia(c.params.curriculum)
    @info "Blocking factor: $(blocking_factor(degreeplan.curriculum))"
    @info "Delay factor: $(delay_factor(degreeplan.curriculum))"
    @info "Centrality: $(centrality(degreeplan.curriculum))"
    @info "Complexity: $(complexity(degreeplan.curriculum))"
    render(JSON, julia_to_json(degreeplan))
end

routes() do
    post("/validate", RESTController, validate)
    post("/calculate_metrics", RESTController, calculate_metrics)
    # create degree plan from curriculum
    plug(Plug.Parsers, parsers=[:json])
end

Bukdu.start(8080)