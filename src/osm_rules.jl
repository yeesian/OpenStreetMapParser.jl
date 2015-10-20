# classification
building(w::Way) = haskey(w.tags, "building")
highway(w::Way) = haskey(w.tags, "highway")

# predicates
visible{T <: OSMElement}(obj::T) = (get(obj.tags, "visible", "") != "false")
services(w::Way) = (get(w.tags,"highway", "") == "services")
reverse(w::Way) = (get(w.tags,"oneway", "") == "-1")

function haslanes(w::Way)
    v = get(w.tags, "lanes", "")
    length(v)==1 && '1' <= v[1] <= '9'
end

function oneway(w::Way)
    v = get(w.tags,"oneway", "")

    if v == "false" || v == "no" || v == "0"
        return false
    elseif v == "-1" || v == "true" || v == "yes" || v == "1"
        return true
    end

    highway = get(w.tags,"highway", "")
    junction = get(w.tags,"junction", "")

    return (highway == "motorway" ||
            highway == "motorway_link" ||
            junction == "roundabout")
end

# attributes
lanes(w::Way) = parse(Int, w.tags["lanes"])

# feature class
roadway(w::Way) = highway(w) * get(ROAD_CLASSES, w.tags["highway"], 0)

function walkway(way::Way)
    sidewalk = get(way.tags, "sidewalk", "")
    if sidewalk != "no"
        if haskey(PED_CLASSES, "sidewalk:$(sidewalk)")
            return PED_CLASSES["sidewalk:$(sidewalk)"]
        elseif haskey(PED_CLASSES, way.tags["highway"])
            return PED_CLASSES[way.tags["highway"]]
        end
    end
    return 0
end

function cycleway(w::Way)
    bicycle = get(w.tags, "bicycle", "")
    cycleway = get(w.tags, "cycleway", "")
    highway = get(w.tags, "highway", "")

    cycleclass = "cycleway:$(cycleway)"
    bikeclass = "bicycle:$(bicycle)"

    if bicycle != "no"
        if haskey(CYCLE_CLASSES, cycleclass)
            return CYCLE_CLASSES[cycleclass]
        elseif haskey(CYCLE_CLASSES, bikeclass)
            return CYCLE_CLASSES[bikeclass]
        elseif haskey(CYCLE_CLASSES, highway)
            return CYCLE_CLASSES[highway]
        end
    end
    return 0
end
