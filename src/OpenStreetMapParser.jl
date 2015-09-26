module OpenStreetMapParser
    import LibExpat # XPCallbacks, XPStreamHandler, parsefile)
    import DataFrames # DataFrame, NA
    import LightGraphs
    import Proj4

    export parseOSM, osm2dataframe, createNetwork

    include("osm_classification.jl")
    include("osm_elements.jl")
    include("osm_parser.jl")
    include("osm_dataframes.jl")
    include("osm_rules.jl")
    include("osm_network.jl")
end # module
