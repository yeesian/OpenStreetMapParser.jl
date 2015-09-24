
type Network
    g:: # LightGraphs.DiGraph
    osm_id::Vector{Int}                     # Graph ID (1:n) -> OSM ID
    graph_id::Dict{Int,Int}                 # OSM ID -> Graph ID
    w::SparseMatrixCSC{Float64,Int64}       # Edge weights, indexed by Graph ID
    class::SparseMatrixCSC{Float64,Int64}   # Road class of each edge
end

function osmNetwork(nodes::Nodes, ways::Ways, relations::Relations)
    length(nodes.ids), length(nodes.ids)

end
