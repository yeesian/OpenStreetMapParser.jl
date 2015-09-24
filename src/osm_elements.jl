type Node
    element::Symbol # :None, :Node
    tags::Dict{UTF8String,UTF8String}
    id::Int # initially #undef
    latlon::Tuple{Float64,Float64} # initially #undef

    Node() = new(:None,Dict())
end

# Nodes
# +-----+-------------------+---------------+
# | id  | latlon            | tags...       |
# +-----+-------------------+---------------+
# | Int | (Float64,Float64) | UTF8String... |
# | .   | .                 | .             |
# | .   | .                 | .             |
# | .   | .                 | .             |
# +-----+-------------------+---------------+

type Nodes
    ids::Vector{Int}
    latlon::Dict{Int,Tuple{Float64,Float64}}
    tags::Dict{UTF8String,Dict{Int,UTF8String}}

    Nodes() = new(Int[], Dict{Int,Tuple{Float64,Float64}}(),
                  Dict{UTF8String,Dict{Int,UTF8String}}())
end

type Way
    element::Symbol # :None, :Way
    nodes::Vector{Int}
    tags::Dict{UTF8String,UTF8String}
    id::Int # initially #undef

    Way() = new(:None,Int[],Dict())
end

# Ways
# +-----+-------------------+---------------+
# | id  | nodes (osm id)    | tags...       |
# +-----+-------------------+---------------+
# | Int | Vector{Int}       | UTF8String... |
# | .   | .                 | .             |
# | .   | .                 | .             |
# | .   | .                 | .             |
# +-----+-------------------+---------------+

type Ways
    ids::Vector{Int}
    nodes::Dict{Int,Vector{Int}}
    tags::Dict{UTF8String,Dict{Int,UTF8String}}
    
    Ways() = new(Int[], Dict{Int,Vector{Int}}(),
                 Dict{UTF8String,Dict{Int,UTF8String}}())
end

type Relation
    element::Symbol # :None, :Relation
    members::Vector{Dict{UTF8String,UTF8String}}
    tags::Dict{UTF8String,UTF8String}
    id::Int # initially #undef

    Relation() = new(:None,
                     Dict{UTF8String,UTF8String}[],
                     Dict{UTF8String,UTF8String}())
end

# Relations
# +-----+-----------------------+---------------+
# | id  | members               | tags...       |
# +-----+-----------------------+---------------+
# | Int | Vector{Dict{Str,Str}} | UTF8String... |
# | .   | .                     | .             |
# | .   | .                     | .             |
# | .   | .                     | .             |
# +-----+-----------------------+---------------+

type Relations
    ids::Vector{Int}
    members::Dict{Int,Vector{Dict{UTF8String,UTF8String}}}
    tags::Dict{UTF8String,Dict{Int,UTF8String}}

    Relations() = new(Int[], Dict{Int,Vector{Dict{UTF8String,UTF8String}}}(),
                      Dict{UTF8String,Dict{Int,UTF8String}}())
end