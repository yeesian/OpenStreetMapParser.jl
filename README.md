# OpenStreetMapParser [Not recommended for use]
See [OpenStreetMap.jl](https://github.com/tedsteiner/OpenStreetMap.jl) for now. But if you must:

This package provides basic functionality for parsing [OpenStreetMap](http://www.openstreetmap.org) data in Julia, in the following file formats:

- [x] .osm (XML) # See http://wiki.openstreetmap.org/wiki/OSM_XML
- [ ] .pbf (binary) # See http://wiki.openstreetmap.org/wiki/PBF_Format

For a complete introduction into the OSM project, the OSM API, and the OSM XML file format we
refer to the project’s wiki available at http://wiki.openstreetmap.org/.

## Installation


## OSM Elements

The OpenStreetMap project provides data in the OSM XML format, which consists of three basic elements:

- `Node`: The basic element. (defining points in space)
- `Way`: An ordered interconnection of nodes (defining linear features and area boundaries)
- `Relation`: A grouping of elements (nodes, ways, and relations), which are sometimes used to explain how other elements work together

The following functions are supported:

```julia
parseNodes() # document/examples
parseWays() # document/examples
parseRelations() # document/examples
parseMap() # document/examples
```

Each element has further attributes like the element ID (unique within the corresponding element group) and timestamp. Furthermore, each element may have an arbitrary number of tags (key-value pairs) which describe the element. Ways and relations, in addition, have references to their members’ IDs.

**Remark**: A distinction should be made between *data elements* (a data primitive used to represent semantic objects), and *semantic elements* (which represent the geometry of physical world objects). Data elements are an implementation detail, while semantic elements carry the desired meaning. This will be made clearer in the next section on OSM Features.

## OSM Features
OpenStreetMap represents physical features on the ground (e.g., roads or buildings) using tags attached to its basic data structures (its nodes, ways, and relations). Each tag describes a geographic attribute of the feature being shown by that specific node, way or relation. The community agrees on certain key and value combinations for the most commonly used tags, which act as informal standards. For a comprehensive list of OSM features, we suggest visiting their wiki page here http://wiki.openstreetmap.org/wiki/Map_Features.

## Scope of this Package

1. This package is meant for parsing of small/medium-sized (typically city-sized, <500MB) OSM files. If you're dealing with bigger files, you might want to scope it down into something smaller, or handle it through a database instead.

2. It will be possible with LibExpat, but not particularly profitable for us to selection/filtering of the OSM data within the parser itself. Given the size of the files we expect (c.f. #1), you can either filter/select them *after* the parsing, or roll out your own parser to perform the selection/filtering.

3. All coordinates are unprojected WGS84 (EPSG:4326). You can perform the necessary transformations through Geodesy.jl ~~or LibOGR.jl~~.

4. The availability of high-resolution aerial imagery has led to many features being recorded as areas (building or site outlines), not points, in OpenStreetMap. You will, for example, often find a restaurant or hotel drawn as an area. This might make processing difficult because you have to cater for both types of features even if you are not interested in areas. As the conversion from areas to points is not well-defined, we do not perform it automatically.

5. We will not be providing the following conveniences, but suggest packages that might help (in parentheses):

  - plotting/viewing of the map elements (Compose/Winston) # OpenStreetMapPlotter.jl
  - routing on the road network (LightGraphs/Graphs) # OpenStreetMapRouter.jl
  - map projections/transformations between different coordinate systems (Geodesy/OGR)
  - filtering/selection of data (DataFrames)
  - geometric operations (JuliaGeometry/LibGEOS)

6. We will, on the other hand, support Pull-Requests that updates the package to be in line with official/well-supported frameworks of OSM data.

## References
- [OpenStreetMap and R](http://osmar.r-forge.r-project.org/)
- [OSM Frameworks](http://wiki.openstreetmap.org/wiki/Frameworks)
- [OpenStreetMap Data in Layered GIS Format (pdf)](http://www.geofabrik.de/data/geofabrik-osm-gis-standard-0.6.pdf)
