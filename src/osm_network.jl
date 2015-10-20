type Network
    g::LightGraphs.DiGraph
    osm_id::Vector{Int}                     # Graph ID (1:n) -> OSM ID
    node_id::Dict{Int,Int}                  # OSM ID -> Graph ID
    way_ids::Dict{Tuple{Int,Int},Vector{Int}}    # (Graph ID) -> osm.ways index
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

"collect all the osm indices in the list of ways"
function collect_nodes(ways::Vector{Way})
    way_nodes = Set{Int}()
    for w in ways
        for n in w.nodes
            push!(way_nodes, n)
        end
    end
    collect(way_nodes)
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

"""
construct a road network from the osm data,

* According to the corresponding speeds (for each way) in km/hour.
* If there are multiple ways correpsonding to an edge, it assumes
  that the road classes corresponding to those ways are the same
* Works only with visible road_classes[highways] for now.
"""
function osmnetwork(osm::OSMData, road_speed::Dict{Int,Int}=SPEED_ROADS_URBAN)
    # filter down to roads along highways
    ways = filter(highway, osm.ways)
    ways = ways[map(visible, ways) & ~(map(services, ways))]
    road_class = map(roadway, ways)
    ways = ways[~(road_class .== 0)]
    speed = [road_speed[c] for c in road_class[~(road_class .== 0)]]
    @assert length(speed) == length(ways)

    # collect all nodes found along the roads
    nodes = osm.nodes
    numnodes = length(nodes)
    osm_ids = osm_indices(nodes)
    node_id = node_indices(osm_ids)

    # construct the graph
    edges, way_ids = construct_edges(node_id, ways)
    V = Float64[distance(nodes[e[1]].lonlat, nodes[e[2]].lonlat) / speed[way_ids[e][1]]
                for e in edges]
    edges = reinterpret(Int, edges)
    I = edges[1:2:end] # collect all start nodes
    J = edges[2:2:end] # collect all end nodes
    distmx = sparse(I, J, V, numnodes, numnodes)

    Network(LightGraphs.DiGraph(distmx), osm_ids, node_id, way_ids, distmx)
end

function construct_edges(node_id::Dict{Int,Int}, ways::Vector{Way})
    rev_ways = map(reverse, ways)
    directed_ways = map(oneway, ways)
    edges = Set{Tuple{Int,Int}}()
    way_ids = Dict{Tuple{Int,Int},Vector{Int}}()

    for i in 1:length(ways)
        way = ways[i]
        rev, nrev = rev_ways[i], !rev_ways[i]
        for n in 2:length(way.nodes)
            n0 = node_id[way.nodes[n-1]] # map osm_id -> node_id
            n1 = node_id[way.nodes[n]]
            startnode = n0*nrev + n1*rev # reverse the direction if need be
            endnode = n0*rev + n1*nrev
            
            edge = (startnode, endnode)
            push!(edges, edge)
            !haskey(way_ids, edge) && (way_ids[edge] = Vector{Int}())
            push!(way_ids[edge], i)

            if !directed_ways[i]
                edge = (endnode, startnode)
                push!(edges, edge)
                !haskey(way_ids, edge) && (way_ids[edge] = Vector{Int}())
                push!(way_ids[edge], i)
            end
        end
    end
    collect(edges), way_ids
end
