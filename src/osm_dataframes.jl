# Nodes
# +-----+-------------------+---------------+
# | id  | latlon            | tags...       |
# +-----+-------------------+---------------+
# | Int | (Float64,Float64) | UTF8String... |
# | .   | .                 | .             |
# | .   | .                 | .             |
# | .   | .                 | .             |
# +-----+-------------------+---------------+

function osmDataFrame(nodes::Nodes)
    colnames = collect(keys(nodes.tags))
    nrows, ncols = length(nodes.ids), length(colnames)
    if nrows == 0
        return DataFrames.DataFrame()
    end
    df = DataFrames.DataFrame(vcat([Int,Tuple{Float64,Float64}],fill(UTF8String, ncols)),
                              vcat([:id,:latlon],map(Symbol,colnames)), nrows)
    for i in 1:nrows
        id = nodes.ids[i]
        df[i, 1] = id
        df[i, 2] = nodes.latlon[id]
        for j in 1:ncols
            df[i, j+2] =  get(nodes.tags[colnames[j]], id, DataFrames.NA)
        end
    end
    df
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

function osmDataFrame(ways::Ways)
    colnames = collect(keys(ways.tags))
    nrows, ncols = length(ways.ids), length(colnames)
    if nrows == 0
        return DataFrames.DataFrame()
    end
    df = DataFrames.DataFrame(vcat([Int,Vector{Int}],fill(UTF8String, ncols)),
                              vcat([:id,:nodes],map(Symbol,colnames)), nrows)
    for i in 1:nrows
        id = ways.ids[i]
        df[i, 1] = id
        df[i, 2] = ways.nodes[id]
        for j in 1:ncols
            df[i, j+2] =  get(ways.tags[colnames[j]], id, DataFrames.NA)
        end
    end
    df
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

function osmDataFrame(relations::Relations)
    colnames = collect(keys(relations.tags))
    nrows, ncols = length(relations.ids), length(colnames)
    if nrows == 0
        return DataFrames.DataFrame()
    end
    df = DataFrames.DataFrame(vcat([Int,Vector{Dict{UTF8String,UTF8String}}],fill(UTF8String, ncols)),
                              vcat([:id,:members],map(Symbol,colnames)), nrows)
    for i in 1:nrows
        id = relations.ids[i]
        df[i, 1] = id
        df[i, 2] = relations.members[id]
        for j in 1:ncols
            df[i, j+2] =  get(relations.tags[colnames[j]], id, DataFrames.NA)
        end
    end
    df
end