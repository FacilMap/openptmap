local points = osm2pgsql.define_node_table('planet_osm_point', {
	{ column = 'way', type = 'point' },
	{ column = 'aerialway', type = 'text' },
	{ column = 'amenity', type = 'text' },
	{ column = 'bus', type = 'text' },
	{ column = 'disused', type = 'text' },
	{ column = 'highway', type = 'text' },
	{ column = 'name', type = 'text' },
	{ column = 'public_transport', type = 'text' },
	{ column = 'railway', type = 'text' },
	{ column = 'train', type = 'text' },
})

local lines = osm2pgsql.define_way_table('planet_osm_line', {
	{ column = 'way', type = 'geometry' },
	{ column = 'name', type = 'text' },
	{ column = 'ref', type = 'text' },
	{ column = 'route', type = 'text' },
	{ column = 'line', type = 'text' },
	{ column = 'state', type = 'text' },
})

local polygons = osm2pgsql.define_area_table('planet_osm_polygon', {
	{ column = 'way', type = 'multipolygon' },
	{ column = 'aerialway', type = 'text' },
	{ column = 'amenity', type = 'text' },
	{ column = 'bus', type = 'text' },
	{ column = 'disused', type = 'text' },
	{ column = 'highway', type = 'text' },
	{ column = 'name', type = 'text' },
	{ column = 'public_transport', type = 'text' },
	{ column = 'railway', type = 'text' },
	{ column = 'train', type = 'text' },
})

local keep_route = {"ferry", "train", "light_rail", "subway", "tram", "monorail", "trolleybus", "bus", "aerialway", "funicular"}
local keep_line = {"ferry", "rail", "train", "light_rail", "subway", "tram", "trolleybus", "bus", "funicular"}

local function one_of(value, of)
	for index = 1, #of do
		if of[index] == value then
			return true
		end
	end
	return false
end

local function pick(value, of)
	for index = 1, #of do
		if of[index] == value then
			return value
		end
	end
end

local function keep(tags)
	return (
		(
			one_of(tags.route, {"ferry", "train", "light_rail", "subway", "tram", "monorail", "trolleybus", "bus", "aerialway", "funicular"})
			or one_of(tags.line, {"ferry", "rail", "train", "light_rail", "subway", "tram", "trolleybus", "bus", "funicular"})
			or one_of(tags.public_transport, {"stop_area", "platform"})
			or one_of(tags.railway, {"station", "halt", "tram_stop"})
			or tags.highway == "bus_stop"
			or tags.amenity == "bus_station"
			or tags.aerialway == "station"
		) and not (
			tags.railway == "platform"
		)
	)
end

function osm2pgsql.process_node(object)
	if keep(object.tags) then
		-- points:insert({
		points:add_row({
			-- way = object:as_point(),
			way = { create = 'point' },
			aerialway = pick(object.tags.aerialway, {"station", "yes"}),
			amenity = pick(object.tags.amenity, {"bus_station"}),
			bus = pick(object.tags.bus, {"yes"}),
			disused = pick(object.tags.disused, {"yes"}),
			highway = pick(object.tags.highway, {"bus_stop"}),
			name = object.tags.name,
			public_transport = pick(object.tags.public_transport, {"stop_area", "platform"}),
			railway = pick(object.tags.railway, {"station", "halt", "tram_stop"}),
			train = pick(object.tags.train, {"yes"}),
		})
	end
end

function osm2pgsql.process_way(object)
	if keep(object.tags) then
		if object.tags.amenity or object.tags.area or object.tags.public_transport then
			-- local geom = object:as_multipolygon()

			-- if not geom:is_null() then
			-- 	polygons:insert({
			-- 		way = geom,

			polygons:add_row({
				way = { create = 'area' },
				aerialway = pick(object.tags.aerialway, {"station", "yes"}),
				amenity = pick(object.tags.amenity, {"bus_station"}),
				bus = pick(object.tags.bus, {"yes"}),
				disused = pick(object.tags.disused, {"yes"}),
				highway = pick(object.tags.highway, {"bus_stop"}),
				name = object.tags.name,
				public_transport = pick(object.tags.public_transport, {"stop_area", "platform"}),
				railway = pick(object.tags.railway, {"station", "halt", "tram_stop"}),
				train = pick(object.tags.train, {"yes"}),
			})
		else
			-- local geom = object:as_multilinestring()

			-- if not geom:is_null() then
			-- 	lines:insert({
			-- 		way = geom,

			lines:add_row({
				way = { create = 'line' },
				name = object.tags.name,
				ref = object.tags.ref,
				route = object.tags.route,
				line = object.tags.line,
				state = object.tags.state,
			})
		end
	end
end

function osm2pgsql.process_relation(object)
	osm2pgsql.process_way(object)
end