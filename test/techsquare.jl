using OpenStreetMapParser, FactCheck

MAP_FILENAME = "tech_square.osm"

if !isfile(MAP_FILENAME)
    url = "https://dl.dropboxusercontent.com/u/8297575/$MAP_FILENAME"
    download(url, MAP_FILENAME)
end

nodes = parseNodes(MAP_FILENAME)
@fact length(nodes.ids) => length(nodes.latlon)
@fact length(nodes.ids) => 1410

@fact length(nodes.tags) => 24
@fact sort(collect(keys(nodes.tags))) =>
    UTF8String["FIXME", "addr:housenumber", "addr:postcode", "addr:street",
               "amenity", "atm", "attribution", "bus", "created_by", "crossing",
               "highway", "line", "massgis:geom_id", "name", "network", "noexit",
               "operator", "public_transport", "railway", "ref", "source",
               "traffic_signals:sound", "url", "wikipedia"]

crossing = nodes.tags["crossing"]
@fact length(crossing) => 14
@fact crossing[61326778]   => "traffic_signals"
@fact crossing[1628602211] => "traffic_signals"
@fact crossing[1628602029] => "traffic_signals"
@fact crossing[1705312831] => "zebra"
@fact crossing[1705308323] => "zebra"
@fact crossing[61317367]   => "traffic_signals"
@fact crossing[1628602239] => "traffic_signals"
@fact crossing[1628602041] => "traffic_signals"
@fact crossing[1628602219] => "traffic_signals"
@fact crossing[1628602201] => "traffic_signals"
@fact crossing[61329208]   => "traffic_signals"
@fact crossing[1628602010] => "traffic_signals"
@fact crossing[1705308324] => "zebra"
@fact crossing[61327535]   => "traffic_signals"

noexit = nodes.tags["noexit"]
@fact length(noexit) => 1
@fact noexit[1230207187] => "yes"

line = nodes.tags["line"]
@fact length(line) => 1
@fact line[69480325] => "Red"

railway = nodes.tags["railway"]
@fact length(railway) => 6
railway[1819633311] => "level_crossing"
railway[69480325]   => "station"
railway[365930364]  => "level_crossing"
railway[1819633315] => "level_crossing"
railway[1819633313] => "level_crossing"
railway[1819633310] => "level_crossing"

highway = nodes.tags["highway"]
@fact highway[1034918607] => "crossing"
@fact highway[1053454370] => "traffic_signals"
@fact highway[1052804034] => "traffic_signals"
@fact highway[61318536]   => "traffic_signals"
@fact highway[1829969262] => "crossing"
@fact highway[1053524037] => "traffic_signals"
@fact highway[1829969266] => "crossing"
@fact highway[1052777483] => "traffic_signals"
@fact highway[1829975813] => "crossing"
@fact highway[1053454390] => "crossing"
@fact highway[1068396444] => "crossing"
@fact highway[1829975825] => "crossing"
@fact highway[1052761909] => "traffic_signals"
@fact highway[1053524038] => "crossing"
@fact highway[2291907804] => "crossing"
@fact highway[61321277]   => "traffic_signals"
@fact highway[1068396443] => "crossing"
@fact highway[1829969270] => "crossing"
@fact highway[1705299287] => "turning_circle"
@fact highway[1053508679] => "traffic_signals"

amenity = nodes.tags["amenity"]
@fact length(amenity) => 4
@fact amenity[1710142648] => "bank"
@fact amenity[1914343564] => "restaurant"
@fact amenity[1749306041] => "restaurant"
@fact amenity[182895807]  => "university"

addr = nodes.tags["addr:housenumber"]
@fact length(addr) => 1
@fact addr[1710142648] => "700"

name = nodes.tags["name"]
@fact length(name) => 8
name[1399777651] => "Broadway opp Hampshire St"
name[1710142648] => "MIT Federal Credit Union"
name[1914343564] => "Catalyst"
name[69480325]   => "Alewife"
name[1399777278] => "Broadway @ Galileo Way"
name[1749306041] => "Area Four"
name[182895807] => "McGovern Institute for Brain Research (MIT)"
name[1399777296] => "Broadway @ Hampshire St"

atm = nodes.tags["atm"]
@fact length(atm) => 1
@fact atm[1710142648] => "yes"

@fact nodes.tags["addr:street"] => Dict(1710142648=>"Technology Square")
@fact nodes.tags["addr:postcode"] => Dict(1710142648=>"02139")
@fact nodes.tags["created_by"] => Dict(61327003 => "JOSM", 61327001 => "JOSM",
                                       61326996 => "JOSM", 61326990 => "JOSM",
                                       61326983 => "JOSM", 61326992 => "JOSM",
                                       61326994 => "JOSM", 61327000 => "JOSM",
                                       61317286 => "JOSM", 61332582 => "JOSM")
@fact nodes.tags["ref"] => Dict(1399777651 => "24485", 1399777278 => "2228",
                                1399777296 => "24486")

ways = parseWays(MAP_FILENAME)
@fact length(ways.ids) => 110
@fact length(ways.ids) => length(ways.nodes)
@fact length(ways.tags) => 89
@fact ways.tags["created_by"] => Dict(8615138  => "JOSM",
                                      29860015 => "Potlatch 0.10f",
                                      8616240  => "Potlatch 0.9c")
@fact ways.tags["name:he"] => Dict(27366257=>"המכון הטכנולוגי של מסצ'וסטס")
@fact ways.tags["massgis:DCAM_ID"] => Dict(29835182=>"0")
@fact ways.tags["layer"] => Dict(236626982=>"-1")
@fact ways.tags["gnis:state_id"] => Dict(27366257=>"25")
@fact ways.tags["ref"] => Dict(29740162 => "NE49", 17660188 => "46",
                               29558550 => "NE80", 29609886 => "NE47",
                               29650626 => "NE48", 29803755 => "48")
@fact ways.tags["massgis:OS_DEED_PA"] => Dict(29835182=>"0")
@fact ways.tags["ramp:wheelchair"] => Dict(106991439=>"yes")
@fact ways.tags["massgis:TOWN_ID"] => Dict(29835182=>"49")
@fact length(ways.tags["building"]) => 32
@fact ways.tags["massgis:ref"] => Dict(90719013  => "0 N324", 239457938 => "0 N323",
                                       8614848   => "0 N324", 33720430  => "0 N324",
                                       34065677  => "0 N323", 239457937 => "0 N323",
                                       138749269 => "0 N323", 8614999   => "0 N324")

relations = parseRelations(MAP_FILENAME)

@fact relations.ids => [1763392, 2119819, 2119824, 2119848, 1600292, 1412944]

@fact length(relations.members) => 6
@fact relations.members[2119819] => [Dict("role"=>"outer","type"=>"way","ref"=>"158302371"),
                                     Dict("role"=>"inner","type"=>"way","ref"=>"29860629"),
                                     Dict("role"=>"inner","type"=>"way","ref"=>"29624640")]

@fact relations.members[2119824] => [Dict("role"=>"outer","type"=>"way","ref"=>"38096750"),
                                     Dict("role"=>"inner","type"=>"way","ref"=>"29947888"),
                                     Dict("role"=>"inner","type"=>"way","ref"=>"29810320"),
                                     Dict("role"=>"inner","type"=>"way","ref"=>"29863742"),
                                     Dict("role"=>"inner","type"=>"way","ref"=>"158302371")]
@fact relations.members[2119848] => [Dict("role"=>"outer","type"=>"way","ref"=>"158305166"),
                                    Dict("role"=>"inner","type"=>"way","ref"=>"158305165"),
                                    Dict("role"=>"inner","type"=>"way","ref"=>"158305356")]
@fact relations.members[1763392] => [Dict("role"=>"via","type"=>"node","ref"=>"1034918626"),
                                     Dict("role"=>"from","type"=>"way","ref"=>"8615585"),
                                     Dict("role"=>"to","type"=>"way","ref"=>"233319829")]
@fact length(relations.members[1600292]) => 58
@fact length(relations.members[1412944]) => 18

@fact length(relations.tags) => 17
@fact relations.tags["name"] => Dict(2119824 => "One Kendall Square",
                                     1600292 => "Red Line",
                                     1412944 => "Grand Junction Branch")
@fact relations.tags["wikipedia"] => Dict(1600292=>"en:Red Line (MBTA)")
@fact relations.tags["old_railway_operator"] => Dict(1412944=>"NYC")
@fact relations.tags["ref"] => Dict(1600292=>"Red Line")
@fact relations.tags["landuse"] => Dict(2119824=>"commercial")
@fact relations.tags["colour"] => Dict(1600292=>"#FF0000")
@fact relations.tags["route"] => Dict(1600292=>"subway",1412944=>"railway")
@fact relations.tags["area"] => Dict(2119819=>"yes",2119848=>"yes")
@fact relations.tags["highway"] => Dict(2119819=>"pedestrian",2119848=>"pedestrian")
@fact relations.tags["operator"] => Dict(1600292=>"MTBA")
@fact relations.tags["restriction"] => Dict(1763392=>"no_right_turn")
@fact relations.tags["network"] => Dict(1600292=>"BOS subway")
@fact relations.tags["website"] => Dict(2119824=>"http://www.onekendallsquare.com/")
@fact relations.tags["to"] => Dict(1600292=>"Mattapan")
@fact relations.tags["from"] => Dict(1600292=>"Alewife")
@fact relations.tags["type"] => Dict(2119819 => "multipolygon",
                                     2119824 => "multipolygon",
                                     2119848 => "multipolygon",
                                     1763392 => "restriction",
                                     1600292 => "route",
                                     1412944 => "route")
@fact relations.tags["FIXME"] => Dict(1412944=>"Was this originally continuous?")

nodes_df = osmDataFrame(nodes)
ways_df = osmDataFrame(ways)
relations_df = osmDataFrame(relations)

building = ways.tags["building"]
@fact length(building) => 32
@fact building[29842810]  => "yes"
@fact building[29740162]  => "university"
@fact building[29810276]  => "yes"
@fact building[37095599]  => "yes"
@fact building[212292730] => "yes"
@fact building[29866161]  => "yes"
@fact building[29627050]  => "yes"
@fact building[29625886]  => "yes"
@fact building[29627492]  => "yes"
@fact building[29628336]  => "yes"
@fact building[29947888]  => "yes"
@fact building[29575544]  => "yes"
@fact building[29558550]  => "university"
@fact building[29609886]  => "university"
@fact building[29862486]  => "yes"
@fact building[29650626]  => "university"
@fact building[29616645]  => "yes"
@fact building[29650632]  => "yes"

highways = ways.tags["highway"]
@fact length(highway) => 55
@fact highway[84967434]  => "footway"
@fact highway[106989193] => "footway"
@fact highway[158302370] => "service"
@fact highway[8615863]   => "footway"
@fact highway[34032974]  => "cycleway"
@fact highway[106987173] => "footway"
@fact highway[39551418]  => "footway"
@fact highway[239457940] => "secondary"
@fact highway[90758903]  => "secondary"
@fact highway[58336059]  => "service"
@fact highway[158304546] => "service"
@fact highway[106989189] => "pedestrian"
@fact highway[8614893]   => "secondary"
@fact highway[239457935] => "secondary"
@fact highway[8616187]   => "residential"
@fact highway[239457936] => "secondary"
@fact highway[149924230] => "secondary"
@fact highway[8615495]   => "secondary"
@fact highway[90719013]  => "secondary"
@fact highway[239457939] => "secondary"

