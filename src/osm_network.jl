
type RoadDist{T} <: AbstractArray{T, 2}
    dist::Dict{Tuple{Int,Int}, T}
    shape::Tuple{Int,Int}
end
Base.getindex(w::RoadDist, s::Int, d::Int) = w.dist[(s,d)]
Base.size(::RoadDist) = (typemax(Int), typemax(Int))

type Network
    g::LightGraphs.DiGraph
    osm_id::Vector{Int}     # Graph ID (1:n) -> OSM ID
    node_id::Dict{Int,Int}  # OSM ID -> Graph ID
    w::RoadDist             # Edge weights, indexed by Graph ID
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

function numedges(ways::Vector{Way})
    n = -length(ways)
    for way in ways
        n += length(way.nodes)
    end
    n
end

function createNetwork(osm::OSMData) #, relations::Relations)
    wgs84 = Proj4.Projection(Proj4.epsg[4269])
    nodes = osm.nodes
    ways = osm.ways
    numnodes = length(nodes)
    osm_id = osm_indices(nodes)
    node_id = node_indices(osm_id)

    g = LightGraphs.DiGraph(numnodes)
    w = RoadDist(Dict{Tuple{Int,Int}, Float64}(), (numnodes,numnodes))
    sizehint!(w.dist, numedges(ways))
    
    ways = ways[map(visible, ways) & ~(map(services, ways))]
    rev_ways = map(reverse, ways)
    directed_ways = map(oneway, ways)

    for i in 1:length(ways)
        way = ways[i]
        rev, nrev = rev_ways[i], !rev_ways[i]
        directed = directed_ways[i]

        for n in 2:length(way.nodes)
            n0 = node_id[way.nodes[n-1]]
            n1 = node_id[way.nodes[n]]
            startnode = n0*nrev + n1*rev
            endnode = n0*rev + n1*nrev
            
            startpt = nodes[startnode].lonlat
            endpt = nodes[endnode].lonlat
            distance = abs(Proj4.geod_distance(startpt, endpt, wgs84))

            if !LightGraphs.has_edge(g, startnode, endnode)
                LightGraphs.add_edge!(g, startnode, endnode)
                w.dist[(startnode, endnode)] = distance
            end
            if !directed && !LightGraphs.has_edge(g, endnode, startnode)
                LightGraphs.add_edge!(g, endnode, startnode)
                w.dist[(endnode, startnode)] = distance # proxy
            end
        end
    end

    Network(g, osm_id, node_id, w)
end
