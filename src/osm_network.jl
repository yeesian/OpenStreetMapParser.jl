type Network
    g::LightGraphs.DiGraph
    osm_id::Vector{Int}                     # Graph ID (1:n) -> OSM ID
    node_id::Dict{Int,Int}                  # OSM ID -> Graph ID
    distmx::SparseMatrixCSC{Float64, Int}   # Edge weights, indexed by Graph ID
end

"fetch all osm ids from the list of osm elements"
function osm_indices{T <: OSMElement}(osm_elements::Vector{T})
    osm_id = Array(Int, length(osm_elements))
    for i in 1:length(osm_elements)
        osm_id[i] = osm_elements[i].id
    end
    osm_id
end

"construct reverse mapping from osmid -> nodeid"
function node_indices(osm_id::Vector{Int})
    node_id = Dict{Int,Int}()
    sizehint!(node_id, length(osm_id))
    for i in 1:length(osm_id)
        node_id[osm_id[i]] = i
    end
    node_id
end

toradians(degree::Float64) = degree * π / 180.0
todegrees(radian::Float64) = radian * 180.0 / π

"distance between the two points in kilometres"
function distance(pt1::Tuple{Float64, Float64}, pt2::Tuple{Float64, Float64})
    dLat = toradians(pt2[2] - pt1[2])
    dLon = toradians(pt2[1] - pt1[1])
    lat1 = toradians(pt1[2])
    lat2 = toradians(pt2[2])
    a = sin(dLat/2)^2 + sin(dLon/2)^2 * cos(lat1) * cos(lat2)
    2.0 * atan2(sqrt(a), sqrt(1-a)) * 6373.0
end

function osm2digraph(osm::OSMData) #, relations::Relations)
    nodes = osm.nodes; ways = osm.ways
    numnodes = length(nodes)
    osm_id = osm_indices(nodes)
    node_id = node_indices(osm_id)
    
    ways = ways[map(visible, ways) & ~(map(services, ways))]
    rev_ways = map(reverse, ways)
    directed_ways = map(oneway, ways)
    edges = Set{Tuple{Int,Int}}()

    for i in 1:length(ways)
        way = ways[i]
        rev, nrev = rev_ways[i], !rev_ways[i]
        for n in 2:length(way.nodes)
            n0 = node_id[way.nodes[n-1]] # map osm_id -> node_id
            n1 = node_id[way.nodes[n]]
            startnode = n0*nrev + n1*rev # reverse the direction if need be
            endnode = n0*rev + n1*nrev
            push!(edges, (startnode, endnode))
            !directed_ways[i] && push!(edges, (endnode, startnode))
        end
    end

    edges = reinterpret(Int, collect(edges))
    I = edges[1:2:end] # collect all start nodes
    J = edges[2:2:end] # collect all end nodes
    V = Float64[distance(nodes[I[i]].lonlat, nodes[J[i]].lonlat)
                for i in 1:length(I)]
    distmx = sparse(I, J, V, numnodes, numnodes)

    Network(LightGraphs.DiGraph(distmx), osm_id, node_id, distmx)
end
