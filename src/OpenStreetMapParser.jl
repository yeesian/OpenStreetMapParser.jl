module OpenStreetMapParser
    import LibExpat # XPCallbacks, XPStreamHandler, parsefile)
    import Compat
    # import DataFrames # DataFrame, NA

    export parseNodes, parseWays, parseRelations #, osmDataFrame

    include("osm_classification.jl")
    include("osm_elements.jl")
    include("osm_parser.jl")
    #include("osm_dataframes.jl")
    # include("osm_network.jl")
end # module
