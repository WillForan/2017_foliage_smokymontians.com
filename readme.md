# Peak Color
![screenshot](screenshot.png?raw=true "screenshot")

Scrap peak color map from https://smokymountains.com/fall-foliage-map/ to create a kml file. Useful for overlaying with other landmarks.

I'm interseted in PA (laural highlands, ANF) and WV (coopers rock,dolly sodds, new river gorgea). FIPS are 42 and 54. 

## Files
* script: `mkkml.bash`
* final output: `leaves.kml` for exploring with marble, google-earth, etc
* input: `cb_2016_*_cousub_500k.kml` (FIPS shapes) `foliage_201710*.csv` (peak color)
  * https://smokymountains.com/fall-foliage-map/
  * https://www.census.gov/geo/maps-data/data/kml/kml_cousub.html
    * https://smokymountains.com/wp-content/themes/smcom-2015/js/foliage2.tsv
    * https://smokymountains.com/wp-content/themes/smcom-2015/js/foliage-2017.csv

## Scaping
Rather than reimplement the logic, we can scrap from the already rendered page.

```
# firefox dev console -> clipboard
window.location='https://smokymountains.com/fall-foliage-map/'
copy( JSON.stringify( $("svg>g>path").map(function(i,f){return([[f.getAttribute('county'),f.getAttribute('class')]])}).get() ))
# shell
xclip -o|jq '.[]|@csv' -r|sed 's/"//g; s/f-/f/; > foliage_20171015.csv
```

## See Also
* http://maps.dcnr.pa.gov/storymaps/fallfoliage/
* http://www.dcnr.pa.gov/Conservation/ForestsAndTrees/FallFoliageReports/Pages/default.aspx
* https://weather.com/maps/fall-foliage
