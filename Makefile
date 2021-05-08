
CSV=data/Mass-2010-blocks-by-race/nhgis0038_csv/nhgis0038_ds172_2010_block.csv
SHP=data/Mass-2010-blocks-by-race/nhgis0038_shape/nhgis0038_shapefile_tl2010_250_block_2010/MA_block_2010.shp

FIELDS="GISJOIN,Total,White,Black or African American,American Indian and Alaska Native,Asian,Native Hawaiian and Other Pacific Islander,Other,Two or More Races"

# NHGIS code:  H7X
#     H7X001:      Total
#     H7X002:      White alone
#     H7X003:      Black or African American alone
#     H7X004:      American Indian and Alaska Native alone
#     H7X005:      Asian alone
#     H7X006:      Native Hawaiian and Other Pacific Islander alone
#     H7X007:      Some Other Race alone
#     H7X008:      Two or More Races

data/ma-2010-race-no-headers.csv: $(CSV)
	xsv select GISJOIN,H7X001,H7X002,H7X003,H7X004,H7X005,H7X006,H7X007,H7X008 $^ | tail -n +2 > $@

data/ma-2010-race.csv: data/ma-2010-race-no-headers.csv
	echo $(FIELDS) > $@
	cat $^ >> $@

data/ma-2010-race.geojson: data/ma-2010-race.csv $(SHP)
	mapshaper $(SHP) -join data/ma-2010-race.csv keys=GISJOIN,GISJOIN field-types=GISJOIN:str \
		-filter 'Total > 0' \
		-proj wgs84 \
		-o $@

data/suffolk-2010-race.geojson: data/ma-2010-race.geojson
	mapshaper $^ -filter 'COUNTYFP10 === "025"' -o $@

output/ma-2010-race-points.csv: data/ma-2010-race.geojson
	pipenv run dorchester plot $^ $@ --progress \
	  -k White \
	  -k "Black or African American" \
	  -k "American Indian and Alaska Native" \
	  -k "Asian" \
	  -k "Native Hawaiian and Other Pacific Islander" \
	  -k Other \
	  -k "Two or More Races"

output/suffolk-2010-race-points.csv: data/suffolk-2010-race.geojson
	pipenv run dorchester plot $^ $@ --progress \
	  -k White \
	  -k "Black or African American" \
	  -k "American Indian and Alaska Native" \
	  -k "Asian" \
	  -k "Native Hawaiian and Other Pacific Islander" \
	  -k Other \
	  -k "Two or More Races"

output/suffolk-2010-race.mbtiles: output/suffolk-2010-race-points.csv
	tippecanoe -zg -o $@ --drop-densest-as-needed --extend-zooms-if-still-dropping $^
