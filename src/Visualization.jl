using Blink, JSON, WebIO, HTTP
import HTTP.Messages

const LOCAL_EMBED_PORT = 8156
const LOCAL_EMBED_FOLDER = "embed_client/dist"
# const REMOTE_EMBED_URL = "https://curricula-api-embed.damoursystems.com/"

# Get the embedable url for the iFrame.
# Remote embeding has been depricated, only local server embeding is now supported
function get_embed_url()
    # try
    #     HTTP.request("GET", REMOTE_EMBED_URL)
    #     return REMOTE_EMBED_URL
    # catch
        local_embed_url = string("http://localhost:", LOCAL_EMBED_PORT)
        try
            HTTP.request("GET", local_embed_url)
        catch
            serve_local_embed_client()
        end
        return local_embed_url
    # end
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
function visualize(plan::DegreePlan; window=Window(), changed=nothing)
    export_degree_plan(plan)

    w = window

    # Data
    data = JSON.parse(open("./curriculum-data.json"))

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

    # Write window body
    body!(
        w,

        # scoped by WebIO
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
    )

    return w
end