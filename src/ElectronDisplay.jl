module ElectronDisplay

using Electron, Base64

struct ElectronDisplayType <: Base.AbstractDisplay end


function Base.display(d::ElectronDisplayType, ::MIME{Symbol("image/png")}, x)
    img = stringmime(MIME("image/png"), x)

    payload = string("<img src=\"data:image/png;base64,", img, "\"/>")

    w = Electron.Window(payload)
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("image/png")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("image/svg+xml")}, x)
    payload = stringmime(MIME("image/svg+xml"), x)

    w = Electron.Window(payload)
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("image/svg+xml")}) = true

asset(url...) = replace(normpath(joinpath(@__DIR__, "..", "assets", url...)), "\\" => "/")

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v2+json")}, x)
    payload = stringmime(MIME("application/vnd.vegalite.v2+json"), x)

    html_page = """
    <html>

    <head>
        <script src="file:///$(asset("vega", "vega.min.js"))"></script>
        <script src="file:///$(asset("vega", "vega-lite.min.js"))"></script>
        <script src="file:///$(asset("vega", "vega-embed.min.js"))"></script>
    </head>
    <body>
      <div id="plotdiv"></div>
    </body>

    <style media="screen">
      .vega-actions a {
        margin-right: 10px;
        font-family: sans-serif;
        font-size: x-small;
        font-style: italic;
      }
    </style>

    <script type="text/javascript">

      var opt = {
        mode: "vega-lite",
        actions: false
      }

      var spec = $payload

      vegaEmbed('#plotdiv', spec, opt);

    </script>

    </html>
    """

    w = Electron.Window(html_page, options=Dict("webPreferences" => Dict("webSecurity" => false)))
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v2+json")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v3+json")}, x)
    payload = stringmime(MIME("application/vnd.vega.v3+json"), x)

    html_page = """
    <html>

    <head>
        <script src="file:///$(asset("vega", "vega.min.js"))"></script>
        <script src="file:///$(asset("vega", "vega-embed.min.js"))"></script>
    </head>
    <body>
      <div id="plotdiv"></div>
    </body>

    <style media="screen">
      .vega-actions a {
        margin-right: 10px;
        font-family: sans-serif;
        font-size: x-small;
        font-style: italic;
      }
    </style>

    <script type="text/javascript">

      var opt = {
        mode: "vega",
        actions: false
      }

      var spec = $payload

      vegaEmbed('#plotdiv', spec, opt);

    </script>

    </html>
    """

    w = Electron.Window(html_page, options=Dict("webPreferences" => Dict("webSecurity" => false)))
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v3+json")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.plotly.v1+json")}, x)
    payload = stringmime(MIME("application/vnd.plotly.v1+json"), x)

    html_page = """
    <html>

    <head>
        <script src="file:///$(asset("plotly", "plotly-latest.min.js"))"></script>
    </head>
    <body>
    </body>

    <script type="text/javascript">
        gd = (function() {
            var WIDTH_IN_PERCENT_OF_PARENT = 100
            var HEIGHT_IN_PERCENT_OF_PARENT = 100;
            var gd = Plotly.d3.select('body')
                .append('div').attr("id", "plotdiv")
                .style({
                    width: WIDTH_IN_PERCENT_OF_PARENT + '%',
                    'margin-left': (100 - WIDTH_IN_PERCENT_OF_PARENT) / 2 + '%',
                    height: HEIGHT_IN_PERCENT_OF_PARENT + 'vh',
                    'margin-top': (100 - HEIGHT_IN_PERCENT_OF_PARENT) / 2 + 'vh'
                })
                .node();
            var spec = $payload
            Plotly.newPlot(gd, spec.data, spec.layout);
            window.onresize = function() {
                Plotly.Plots.resize(gd);
                };
            return gd;
        })();
    </script>

    </html>
    """

    w = Electron.Window(html_page, options=Dict("webPreferences" => Dict("webSecurity" => false)))
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.plotly.v1+json")}) = true

function Base.display(d::ElectronDisplayType, x)
    if showable("application/vnd.vegalite.v2+json", x)
        display(d,MIME("application/vnd.vegalite.v2+json"), x)
    elseif showable("application/vnd.vega.v3+json", x)
            display(d,MIME("application/vnd.vega.v3+json"), x)
    elseif showable("application/vnd.plotly.v1+json", x)
            display(d,MIME("application/vnd.plotly.v1+json"), x)
    elseif showable("image/svg+xml", x)
        display(d,"image/svg+xml", x)
    elseif showable("image/png", x)
        display(d,"image/png", x)
    else
        throw(MethodError(Base.display,(d,x)))
    end
end

function __init__()
    Base.Multimedia.pushdisplay(ElectronDisplayType())
end

end # module
