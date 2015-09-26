abstract OSMElement

# Nodes
# +-----+-------------------+---------------+
# | id  | lonlat            | tags...       |
# +-----+-------------------+---------------+
# | Int | (Float64,Float64) | UTF8String... |
# | .   | .                 | .             |
# | .   | .                 | .             |
# | .   | .                 | .             |
# +-----+-------------------+---------------+

type Node <: OSMElement
    id::Int
    lonlat::Tuple{Float64,Float64}
    tags::Dict{UTF8String,UTF8String}
    Node(id::Int, lonlat::Tuple{Float64,Float64}) = new(id, lonlat)
end

function tags(n::Node) # lazily create tags
    isdefined(n, :tags) || (n.tags = Dict{UTF8String,UTF8String}())
    n.tags
end

# Node(id::Int, lonlat::Tuple{Float64,Float64}) =
#     Node(id, lonlat, Dict{UTF8String,UTF8String}())

# Ways
# +-----+-------------------+---------------+
# | id  | nodes (osm id)    | tags...       |
# +-----+-------------------+---------------+
# | Int | Vector{Int}       | UTF8String... |
# | .   | .                 | .             |
# | .   | .                 | .             |
# | .   | .                 | .             |
# +-----+-------------------+---------------+

type Way <: OSMElement
    id::Int
    nodes::Vector{Int}
    tags::Dict{UTF8String,UTF8String}
    Way(id::Int) = new(id, Vector{Int}(), Dict{UTF8String,UTF8String}())
end
tags(w::Way) = w.tags

# Way(id::Int) = Way(id, Vector{Int}(), Dict{UTF8String,UTF8String}())

# Relations
# +-----+-----------------------+---------------+
# | id  | members               | tags...       |
# +-----+-----------------------+---------------+
# | Int | Vector{Dict{Str,Str}} | UTF8String... |
# | .   | .                     | .             |
# | .   | .                     | .             |
# | .   | .                     | .             |
# +-----+-----------------------+---------------+

type Relation <: OSMElement
    id::Int
    members::Vector{Dict{UTF8String,UTF8String}}
    tags::Dict{UTF8String,UTF8String}
    Relation(id::Int) = new(id, Vector{Dict{UTF8String,UTF8String}}(),
                            Dict{UTF8String,UTF8String}())
end
tags(r::Relation) = r.tags

# Relation(id::Int) = Relation(id, Vector{Dict{UTF8String,UTF8String}}(),
#                              Dict{UTF8String,UTF8String}())
