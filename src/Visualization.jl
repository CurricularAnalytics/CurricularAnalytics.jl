using Blink, JSON, WebIO, HTTP
import HTTP.Messages

const LOCAL_EMBED_PORT = 8156
const LOCAL_EMBED_FOLDER = "./embed_client/dist"

function get_embed_url()
        local_embed_url = string("http://localhost:", LOCAL_EMBED_PORT)
        try
            HTTP.request("GET", local_embed_url)
        catch
            serve_local_embed_client()
        end
        return local_embed_url
end

# Serve a local embed client on port 8156
function serve_local_embed_client()
    @async HTTP.listen(HTTP.Sockets.localhost, LOCAL_EMBED_PORT) do req::HTTP.Request
        # default render index.html case
        req.target == "/" && return HTTP.Response(200, read(joinpath(LOCAL_EMBED_FOLDER, "index.html")))

        # construct file location from request target
        file = joinpath(LOCAL_EMBED_FOLDER, HTTP.unescapeuri(req.target[2:end]))

        # determine / set content type
        content_type = "text/html"
        if (occursin(r".js$", file))          
        content_type = "application/javascript"
        elseif (occursin(r".css$", file))     
        content_type = "text/css"
        end
        Messages.setheader(req, "Content-Type" => content_type)

        # return file or 404 if not present
        return isfile(file) ? HTTP.Response(200, read(file)) : HTTP.Response(404)
    end
end

# Main visualization function. Pass in degree plan to be visualized. Optionally a window 
# prop can be passed in to specify the render where the visualization should be rendered.
# Additional changed callback may be provided which will envoke whenever the curriculum is 
# modified through the interfaces.
"""
     visualize(curriculum; <keyword arguments>))

Visualize a curriculum. 
# Arguments
Required:
- `curriculum::Curriculum` : the curriculum to visualize.
# Arguments
Required:
- `degree_plan::DegreePlan` : the name of the curriculum.
Keyword:
- `window` : funtion argument that specifies the window to render content in. 
   Default is `Window()`.
- `changed` : callback function argument, called whenever the curriculum is modified through the interface.
    Default is `nothing`.
- `file_name` : name of the file, in JSON format, that will the degree plan, including modifications. 
    Default is `recent-visualization.json`.
"""

function visualize(curric::Curriculum; notebook::Bool=false, edit::Bool=false)
    num_courses = length(curric.courses)
    if num_courses <= 8
        term_count = 3
        max_credit_each_term = 6
    elseif num_courses <= 16
        term_count = 4
        max_credit_each_term = 9
    elseif num_courses <= 24
        term_count = 5
        max_credit_each_term = 12
    elseif num_courses <= 32
        term_count = 6
        max_credit_each_term = 15
    elseif num_courses <= 40
        term_count = 7
        max_credit_each_term = 18
    elseif num_courses <= 48
        term_count = 8
        max_credit_each_term = 21
    elseif num_courses <= 56
        term_count = 9
        max_credit_each_term = 24
    else
        error("Curriculum is too big to visualize.")
    end
    terms = create_terms(curric, term_count, max_credit_each_term::Int)
    dp = DegreePlan("temp plan", curric, terms)
    viz_helper(dp; notebook=notebook, edit=edit, hide_header=true)
end

function visualize(plan::DegreePlan; changed=nothing, notebook::Bool=false, edit::Bool=false)
   viz_helper(plan; changed=changed, notebook=notebook, edit=edit)
end

# Main visualization function. A "changed" callback function may be provided which will be invoked whenever the 
# curriculum/degere plan is modified through the interface.
"""
    visualize(degree_plan; <keyword arguments>))
Visualize a degree plan. 
# Arguments
Required:
- `degree_plan::DegreePlan` : the degree plan to visualize.
 Keyword:
 - `changed` : callback function argument, called whenever the curriculum is modified through the interface.
     Default is `nothing`.
 - `notebook` : a Boolean argument, if set to true, the degree will be displayed within a Jupyter notebook
 - `edit` : a Boolean argument, the user may edit the degree plan through the visualziation interface.
"""
function viz_helper(plan::DegreePlan; changed=nothing, file_name="recent-visualization.json", notebook=false, edit=true, hide_header=false)
    write_degree_plan(plan, file_name)

    # Data
    data = JSON.parse(open("./" * file_name))
	data["options"] = Dict{String, Any}()
    data["options"]["edit"]=edit
    data["options"]["hideTerms"]=hide_header
    # Setup data observation to check for changes being made to curriculum
    s = Scope()

    obs = Observable(s, "curriculum-data", data)

    on(obs) do new_data
        if (isa(changed, Function)) 
            changed(new_data)
        end
    end

    # iFrame onload event handler
    iframe_loaded = @js function ()
        # when iFrame loaded, post curriculum data to it
        this.contentWindow.postMessage($data, "*")
        # listen for changes to the curriculum and make the observable aware
        # make sure the previous handler is removed before adding the new one
        window.removeEventListener("message", window.messageReceived)
        window.messageReceived = function (event)
            if (event.data.curriculum !== undefined) 
                $obs[] = event.data.curriculum
            end
        end
        window.addEventListener("message", window.messageReceived)
    end
	
	s(
            dom"iframe#curriculum"(
                "", 
                # iFrame source
                src=get_embed_url(),
                # iFrame styles
                style=Dict(
                    :width => "100%",
                    :height => "100vh",
                    :margin => "0",
                    :padding => "0",
                    :border => "none"
                ),
                events=Dict(
                    # iFrame onload event
                    :load => iframe_loaded
                )
            )
        )
    if (notebook == true)
        # scoped by WebIO
        s
    else
        # Write window body
		w=Window()
        body!(
            w,

            # scoped by WebIO
            s
        )
        return w
    end
end