using Gumbo
using JSON
using Blink

function visualize(plan::DegreePlan)
    export_degreeplan(plan)
    # Define new window through Blink
    w = Window()
    # Window is asynchronous so by sleeping for 1 second we ensure it is ready
    sleep(5)
    # The template contains the styling of the page and the iframe for the curriculum data to populate
    template = read(open("./visualization-template.html"), String)
    # Data
    data = JSON.parse(open("./curriculum-data.json"))
    # Write body
    body!(w, template, async=false)
    # Callback function that posts the data once the iframe is loaded
    callback_send = @js a -> document.getElementById("curriculum").contentWindow.postMessage($data, "*")

    callback_listen = @js event -> 
    if (event.data.curriculum !== undefined) 
        console.log(event.data.curriculum) 
    end

    @js w begin
        document.getElementById("curriculum").addEventListener("load", $callback_send)
        window.addEventListener("message", $callback_listen)
    end
end