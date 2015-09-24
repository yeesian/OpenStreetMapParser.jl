# Example (Node)
# -------
# <node id="61327001" visible="true" version="1" changeset="64956"
#       timestamp="2007-10-08T23:40:44Z" user="MassGIS Import"
#       uid="15750" lat="42.3627260" lon="-71.0936790">
#   <tag k="attribution"
#        v="Office of Geographic and Environmental Information (MassGIS)"/>
#   <tag k="created_by" v="JOSM"/>
#   <tag k="source" v="massgis_import_v0.1_20071008165629"/>
# </node>

type NodeHandle
    curr::Node
    nodes::Nodes
end

function parseNode(handler::LibExpat.XPStreamHandler,
                   name::String,
                   attr::Dict{String,String})
    curr = handler.data.curr::Node
    if name == "node"
        curr.element = :Node
        curr.id = parse(Int, attr["id"])
        curr.latlon = (float(attr["lat"]), float(attr["lon"]))
    elseif name == "tag" && curr.element == :Node
        curr.tags[attr["k"]] = attr["v"]
    end
end

function collectNode(handler::LibExpat.XPStreamHandler, name::String)
    nodes = handler.data.nodes::Nodes
    curr = handler.data.curr::Node
    if name == "node"
        nodes.latlon[curr.id] = curr.latlon
        push!(nodes.ids, curr.id)
        for key in keys(curr.tags)
            if !haskey(nodes.tags, key)
                nodes.tags[key] = Dict{Int,UTF8String}()
            end
            nodes.tags[key][curr.id] = curr.tags[key]
        end
        # reset element
        curr.element = :None
        curr.tags = Dict()
    end
end

function parseNodes(filename::String; args...)
    nodehandle = NodeHandle(Node(), Nodes())
    callbacks = LibExpat.XPCallbacks()
    callbacks.start_element = parseNode
    callbacks.end_element = collectNode
    LibExpat.parsefile(filename, callbacks, data=nodehandle; args...)
    nodehandle.nodes::Nodes
end

# Example (Way)
# -------
# <way id="5090250" visible="true" timestamp="2009-01-19T19:07:25Z" version="8"
#      changeset="816806" user="Blumpsy" uid="64226">
#     <nd ref="822403"/>
#     <nd ref="21533912"/>
#     ...
#     <nd ref="135791608"/>
#     <nd ref="823771"/>
#     <tag k="highway" v="residential"/>
#     <tag k="name" v="Clipstone Street"/>
#     <tag k="oneway" v="yes"/>
#   </way>

type WayHandle
    curr::Way
    ways::Ways
end

function parseWay(handler::LibExpat.XPStreamHandler,
                  name::String,
                  attr::Dict{String,String})
    curr = handler.data.curr::Way
    if name == "way"
        curr.element = :Way
        curr.id = parse(Int, attr["id"])
    elseif curr.element == :Way
        if name == "tag"
            curr.tags[attr["k"]] = attr["v"]
        elseif name == "nd"
            push!(curr.nodes, parse(Int, attr["ref"]))
        end
    end
end

function collectWay(handler::LibExpat.XPStreamHandler, name::String)
    ways = handler.data.ways::Ways
    curr = handler.data.curr::Way
    if name == "way"
        push!(ways.ids, curr.id)
        ways.nodes[curr.id] = curr.nodes
        for key in keys(curr.tags)
            if !haskey(ways.tags, key)
                ways.tags[key] = Dict{Int,UTF8String}()
            end
            ways.tags[key][curr.id] = curr.tags[key]
        end
        curr.element = :None
        curr.nodes = Int[]
        curr.tags = Dict()
    end
end

function parseWays(filename::String; args...)
    wayhandle = WayHandle(Way(), Ways())
    callbacks = LibExpat.XPCallbacks()
    callbacks.start_element = parseWay
    callbacks.end_element = collectWay
    LibExpat.parsefile(filename, callbacks, data=wayhandle; args...)
    wayhandle.ways::Ways
end

# Example (Relation)
# <relation id="1">
#   <tag k="type" v="multipolygon" />
#   <member type="way" id="1" role="outer" />
#   <member type="way" id="2" role="outer" />
#   ...
#   <member type="way" id="19" role="inner" />
#   <member type="way" id="20" role="outer" />
# </relation>

type RelationHandle
    curr::Relation
    relations::Relations
end

function parseRelation(handler::LibExpat.XPStreamHandler,
                       name::String,
                       attr::Dict{String,String})
    curr = handler.data.curr::Relation
    if name == "relation"
        curr.element = :Relation
        curr.id = parse(Int, attr["id"])
    elseif curr.element == :Relation
        if name == "tag"
            curr.tags[attr["k"]] = attr["v"]
        elseif name == "member"
            push!(curr.members, attr)
        end
    end
end

function collectRelation(handler::LibExpat.XPStreamHandler, name::String)
    relations = handler.data.relations::Relations
    curr = handler.data.curr::Relation
    if name == "relation"
        push!(relations.ids, curr.id)
        relations.members[curr.id] = curr.members
        for key in keys(curr.tags)
            if !haskey(relations.tags, key)
                relations.tags[key] = Dict{Int,UTF8String}()
            end
            relations.tags[key][curr.id] = curr.tags[key]
        end
        curr.element = :None
        curr.members = Dict{UTF8String,UTF8String}[]
        curr.tags = Dict()
    end
end

function parseRelations(filename::String; args...)
    relationhandle = RelationHandle(Relation(), Relations())
    callbacks = LibExpat.XPCallbacks()
    callbacks.start_element = parseRelation
    callbacks.end_element = collectRelation
    LibExpat.parsefile(filename, callbacks, data=relationhandle; args...)
    relationhandle.relations::Relations
end

# ### PARSE OSM ENTITIES ###

# function parse_highway(attr::OSMattributes, k::String, v::String)
#     if k == "highway"
#         attr.class = v
#         if v == "services" # Highways marked "services" are not traversable
#             attr.visible = false
#             return
#         end
#         if v == "motorway" || v == "motorway_link"
#             attr.oneway = true # motorways default to oneway
#         end
#     elseif k == "oneway"
#         if v == "-1"
#             attr.oneway = true
#             attr.oneway_reverse = true
#         elseif v == "false" || v == "no" || v == "0"
#             attr.oneway = false
#             attr.oneway_override = true
#         elseif v == "true" || v == "yes" || v == "1"
#             attr.oneway = true
#         end
#     elseif k == "junction" && v == "roundabout"
#         attr.oneway = true
#     elseif k == "cycleway"
#         attr.cycleway = v
#     elseif k == "sidewalk"
#         attr.sidewalk = v
#     elseif k == "bicycle"
#         attr.bicycle = v
#     elseif k == "lanes" && length(v)==1 && '1' <= v[1] <= '9'
#         attr.lanes = int(v)
#     else
#         return
#     end
#     attr.parent = :Highway
# end

# function parse_building(attr::OSMattributes, v::String)
#     attr.parent = :Building
#     if isempty(attr.class)
#         attr.class = v
#     end
# end

# function parse_feature(attr::OSMattributes, k::String, v::String)
#     attr.parent = :Feature
#     attr.class = k
#     attr.detail = v
# end