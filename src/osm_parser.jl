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

type OSMData
    nodes::Vector{Node}
    ways::Vector{Way}
    relations::Vector{Relation}
    node_tags::Set{UTF8String}
    way_tags::Set{UTF8String}
    relation_tags::Set{UTF8String}
end
OSMData() = OSMData(Vector{Node}(), Vector{Way}(), Vector{Relation}(),
                    Set{UTF8String}(), Set{UTF8String}(), Set{UTF8String}())

type DataHandle
    element::Symbol
    osm::OSMData
    node::Node # initially undefined
    way::Way # initially undefined
    relation::Relation # initially undefined

    DataHandle() = new(:None, OSMData())
end

function parseElement(handler::LibExpat.XPStreamHandler,
                      name::AbstractString,
                      attr::Dict{AbstractString,AbstractString})
    data = handler.data::DataHandle
    if name == "node"
        data.element = :Node
        data.node = Node(parse(Int, attr["id"]),
                         (float(attr["lon"]), float(attr["lat"])))
    elseif name == "way"
        data.element = :Way
        data.way = Way(parse(Int, attr["id"]))
    elseif name == "relation"
        data.element = :Relation
        data.relation = Relation(parse(Int, attr["id"]))
    elseif name == "tag"
        k = attr["k"]; v = attr["v"]
        if data.element == :Node
            data_tags = tags(data.node)
            push!(data.osm.node_tags, k)
        elseif data.element == :Way
            data_tags = tags(data.way)
            push!(data.osm.way_tags, k)
        elseif data.element == :Relation
            data_tags = tags(data.relation)
            push!(data.osm.relation_tags, k)
        end
        data_tags[k] = v
    elseif name == "nd"
        push!(data.way.nodes, parse(Int, attr["ref"]))
    elseif name == "member"
        push!(data.relation.members, attr)
    end
end

function collectElement(handler::LibExpat.XPStreamHandler, name::AbstractString)
    if name == "node"
        push!(handler.data.osm.nodes, handler.data.node)
        handler.data.element = :None
    elseif name == "way"
        push!(handler.data.osm.ways, handler.data.way)
        handler.data.element = :None
    elseif name == "relation"
        push!(handler.data.osm.relations, handler.data.relation)
        handler.data.element = :None
    end
end

function parseOSM(filename::AbstractString; args...)
    callbacks = LibExpat.XPCallbacks()
    callbacks.start_element = parseElement
    callbacks.end_element = collectElement
    data = DataHandle()
    LibExpat.parsefile(filename, callbacks, data=data; args...)
    data.osm::OSMData
end

function parseNode(handler::LibExpat.XPStreamHandler,
                   name::AbstractString,
                   attr::Dict{AbstractString,AbstractString})
    data = handler.data
    if name == "node"
        data.element = :Node
        data.curr = Node(parse(Int, attr["id"]),
                         (float(attr["lon"]), float(attr["lat"])),
                         Dict{UTF8String,UTF8String}())
    elseif name == "tag" && data.element == :Node
        data.curr.tags[attr["k"]] = attr["v"]
    end
end

function collectNode(handler::LibExpat.XPStreamHandler, name::AbstractString)
    if name == "node"
        handler.data.element = :None
        push!(handler.data.nodes, handler.data.curr)
    end
end

function parseNodes(filename::AbstractString; args...)
    callbacks = LibExpat.XPCallbacks()
    callbacks.start_element = parseNode
    callbacks.end_element = collectNode
    nodehandle = NodeHandle()
    LibExpat.parsefile(filename, callbacks, data=nodehandle; args...)
    nodehandle.nodes::Vector{Node}
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
    element::Symbol
    ways::Vector{Way}
    curr::Way # initially undefined
    WayHandle(element::Symbol, ways::Vector{Way}) = new(element, ways)
end

function parseWay(handler::LibExpat.XPStreamHandler,
                  name::AbstractString,
                  attr::Dict{AbstractString,AbstractString})
    if name == "way"
        handler.data.element = :Way
        handler.data.curr = Way(parse(Int, attr["id"]),
                                Vector{Int}(),
                                Dict{UTF8String,UTF8String}())
    elseif handler.data.element == :Way
        if name == "tag"
            handler.data.curr.tags[attr["k"]] = attr["v"]
        elseif name == "nd"
            push!(handler.data.curr.nodes, parse(Int, attr["ref"]))
        end
    end
end

function collectWay(handler::LibExpat.XPStreamHandler, name::AbstractString)
    if name == "way"
        push!(handler.data.ways, handler.data.curr)
        handler.data.element = :None
    end
end

function parseWays(filename::AbstractString; args...)
    wayhandle = WayHandle(:None, Vector{Way}())
    callbacks = LibExpat.XPCallbacks()
    callbacks.start_element = parseWay
    callbacks.end_element = collectWay
    LibExpat.parsefile(filename, callbacks, data=wayhandle; args...)
    wayhandle.ways::Vector{Way}
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
    element::Symbol
    relations::Vector{Relation}
    curr::Relation # initially undefined
    RelationHandle(e::Symbol, relations::Vector{Relation}) = new(e, relations)
end

function parseRelation(handler::LibExpat.XPStreamHandler,
                       name::AbstractString,
                       attr::Dict{AbstractString,AbstractString})
    if name == "relation"
        handler.data.element = :Relation
        handler.data.curr = Relation(parse(Int, attr["id"]),
                                     Vector{Dict{UTF8String,UTF8String}}(),
                                     Dict{UTF8String,UTF8String}())
    elseif handler.data.element == :Relation
        if name == "tag"
            handler.data.curr.tags[attr["k"]] = attr["v"]
        elseif name == "member"
            push!(handler.data.curr.members, attr)
        end
    end
end

function collectRelation(handler::LibExpat.XPStreamHandler, name::AbstractString)
    if name == "relation"
        push!(handler.data.relations, handler.data.curr)
        handler.data.element = :None
    end
end

function parseRelations(filename::AbstractString; args...)
    relationhandle = RelationHandle(:None, Vector{Relation}())
    callbacks = LibExpat.XPCallbacks()
    callbacks.start_element = parseRelation
    callbacks.end_element = collectRelation
    LibExpat.parsefile(filename, callbacks, data=relationhandle; args...)
    relationhandle.relations::Vector{Relation}
end
