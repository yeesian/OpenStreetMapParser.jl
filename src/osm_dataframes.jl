
function collect_tags{T <: OSMElement}(osm_elements::Vector{T})
    tags = Set{UTF8String}()
    for n in osm_elements
        if isdefined(n, :tags)
            for k in keys(n.tags)
                push!(tags, k)
            end
        end
    end
    collect(tags)
end

_field(::Type{Node}) = :latlon
_field(::Type{Way}) = :nodes
_field(::Type{Relation}) = :members
_fieldvalue(node::Node) = node.latlon
_fieldvalue(way::Way) = way.nodes
_fieldvalue(relation::Relation) = relation.members
_fieldtype(::Type{Node}) = Tuple{Float64,Float64}
_fieldtype(::Type{Way}) = Vector{Int}
_fieldtype(::Type{Relation}) = Vector{Dict{UTF8String,UTF8String}}

function osm2dataframe{T <: OSMElement}(osm::Vector{T},
                                        colnames::Vector{UTF8String})
    nrows, ncols = length(osm), length(colnames)
    if nrows == 0
        return DataFrames.DataFrame()
    end
    df = DataFrames.DataFrame(vcat([Int,_fieldtype(T)],
                                   fill(UTF8String, ncols)),
                              vcat([:id, _field(T)],
                                   map(Symbol,colnames)),
                              nrows)
    for i in 1:nrows
        element = osm[i]
        df[i, 1] = element.id
        df[i, 2] = _fieldvalue(element)
        for j in 1:ncols
            if isdefined(element, :tags)
                df[i, j+2] = get(element.tags, colnames[j], DataFrames.NA)
            end
        end
    end
    df
end

osm2dataframe{T <: OSMElement}(osm::Vector{T}) =
    osm2dataframe(osm, collect_tags(osm))
