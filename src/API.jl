#TODO - Inlucde documentation in this file such that it builds to GitHub Pages

using Bukdu

struct RESTController <: ApplicationController
    conn::Conn
end

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
    post("/matrics", RESTController, calculate_metrics)
    # create degree plan from curriculum
    plug(Plug.Parsers, parsers=[:json])
end

Bukdu.start(8080, host="0.0.0.0")