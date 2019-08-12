using JSON
using WebIO
using HTTP
using Blink

import HTTP.Messages

const LOCAL_EMBED_PORT = 8156
const LOCAL_EMBED_FOLDER = joinpath(dirname(pathof(CurricularAnalytics)),"..","embed_client","dist")

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
    @async HTTP.serve(HTTP.Sockets.localhost, LOCAL_EMBED_PORT) do req::HTTP.Request
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

Keyword:

- `changed` : callback function argument, called whenever the curriculum is modified through the interface.
     Default is `nothing`.
- `notebook` : a Boolean argument, if set to `true`, Blink will not create a new window for the visualization, which allows it to be displayed in the output cell of a Jupyter notebook.
- `edit` : a Boolean argument, if set to `true`, the user may edit the curriculum through the visualziation interface. 
   Default is `false`.
- `output_file` : the relative or absolute path to the CSV file that will store the edited curriculum. Default 
   is `edited_curriculum.csv`.
- `show_delay` : a Boolean argument, if set to `true`, the delay factor metric will be displayed in the tooltip when hovering over a course. Default is `false`.
- `show_blocking` : a Boolean argument, if set to `true`, the blocking factor metric will be displayed in the tooltip when hovering over a course. Default is `false`.
- `show_centrality` : a Boolean argument, if set to `true`, the centrality metric will be displayed in the tooltip when hovering over a course. Default is `false`.
- `show_complexity` : a Boolean argument, if set to `true`, the complexity metric will be displayed in the tooltip when hovering over a course. Default is `false`.
- `scale` : a Real value used to scale the size of the output window.

"""
function visualize(curric::Curriculum; changed=nothing, notebook::Bool=false, edit::Bool=false, min_term::Int=1, output_file="edited_curriculum.csv", 
                    show_delay::Bool=false, show_blocking::Bool=false, show_centrality::Bool=false, show_complexity::Bool=false, scale::Real=1)
    num_courses = length(curric.courses)
    if num_courses <= 8
        max_credits_per_term = 12
    elseif num_courses <= 16
        max_credits_per_term = 15
    elseif num_courses <= 24
        max_credits_per_term = 18
    elseif num_courses <= 32
        max_credits_per_term = 18
    elseif num_courses <= 40
        max_credits_per_term = 21
    elseif num_courses <= 48
        max_credits_per_term = 23
    elseif num_courses <= 56
        max_credits_per_term = 26
    else
        error("Curriculum is too big to visualize.")
    end
    term_count = num_courses
    dp = create_degree_plan(curric, bin_packing2; max_terms = term_count, max_credits_per_term = max_credits_per_term)
    viz_helper(dp; changed=changed, notebook=notebook, edit=edit, hide_header=true, output_file=output_file, show_delay=show_delay,
                show_blocking=show_blocking,show_centrality=show_centrality, show_complexity=show_complexity, scale=scale)
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

- `changed` : callback function argument, called whenever the degree plan is modified through the interface.
     Default is `nothing`.
- `notebook` : a Boolean argument, if set to `true`, Blink will not create a new window for the visualization, which allows it to be displayed in the output cell of a Jupyter notebook.
- `edit` : a Boolean argument, if set to `true`, the user may edit the degree plan through the visualziation interface. 
   Default is `false`.
- `output_file` : the relative or absolute path to the CSV file that will store the edited degree plan. Default 
   is `edited_degree_plan.csv`.
- `show_delay` : a Boolean argument, if set to `true`, the delay factor metric will be displayed in the tooltip when hovering over a course. Default is `true`.
- `show_blocking` : a Boolean argument, if set to `true`, the blocking factor metric will be displayed in the tooltip when hovering over a course. Default is `true`.
- `show_centrality` : a Boolean argument, if set to `true`, the centrality metric will be displayed in the tooltip when hovering over a course. Default is `true`.
- `show_complexity` : a Boolean argument, if set to `true`, the complexity metric will be displayed in the tooltip when hovering over a course. Default is `true`.
- `scale` : a Real value used to scale the size of the output window.

"""
function visualize(plan::DegreePlan; changed=nothing, notebook::Bool=false, edit::Bool=false, output_file="edited_degree_plan.csv", 
                    show_delay::Bool=true, show_blocking::Bool=true, show_centrality::Bool=true, show_complexity::Bool=true, scale::Real=1)
   
    viz_helper(plan; changed=changed, notebook=notebook, edit=edit,output_file=output_file, show_delay=show_delay,
                show_blocking=show_blocking, show_centrality=show_centrality, show_complexity=show_complexity, scale=scale)
end

function viz_helper(plan::DegreePlan; changed, notebook, edit, hide_header=false, output_file, show_delay::Bool, 
    show_blocking::Bool, show_centrality::Bool, show_complexity::Bool, scale::Real=1)
    if show_delay
        delay_factor(plan.curriculum)
    end
    if show_blocking
        blocking_factor(plan.curriculum)
    end
    if show_centrality
        centrality(plan.curriculum)
    end
    if show_complexity
        complexity(plan.curriculum)
    end  

    if !Blink.AtomShell.isinstalled() 
        Blink.AtomShell.install()
    end
    # Data
    data = prepare_data(plan, edit=edit, hide_header=hide_header, show_delay=show_delay,
                show_blocking=show_blocking, show_centrality=show_centrality,
                show_complexity=show_complexity)        

    # Setup data observation to check for changes being made to curriculum
    s = Scope()

    obs = Observable(s, "curriculum-data", data)

    on(obs) do new_data
        if (isa(changed, Function)) 
            changed(plan, new_data, output_file)
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
                :height => string(Int(scale*100)) * "vh",
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