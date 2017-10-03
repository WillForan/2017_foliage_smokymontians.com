#!/usr/bin/env bash

########
# make kml of fall foliage from dynamic https://smokymountains.com/fall-foliage-map 
# USAGE:
#   ./mkkml.bash 42 > pa.kml
###
#  scrapped foliage data like:
#    # firefox dev console -> clipboard
#    copy( JSON.stringify( $("svg>g>path").map(function(i,f){return([[f.getAttribute('county'),f.getAttribute('class')]])}).get() ))
#    # clipboard json to csv (+ "style" id f-1 to f1)
#    xclip -o|jq '.[]|@csv' -r|sed 's/"//g; s/f-/f/; > foliage_20171015.csv
###

# pa=42
# wv=54
state=42
fallweekfile=~/foliage_20171015.csv
statekml=cb_2016_${state}_cousub_500k.kml

## create files

#perl -ne 'if(m/((SimpleData name="(NAME|COUNTYFP)")|coordinates)>(.*)</){print $4; print m/coordinates/?"\n":"\t"}' $statekml |
#   cut -d$'\t' -s -f1- |sed "s/^/$state/" > $state.coord

# get outerBoundary for each FIPS, output
#  STATE+COUNTYFIPS, NAME, coords
perl -Mojo -E 'say x(f("'$statekml'")->slurp)->find("Placemark")->map(sub {$c=$_->at("outerBoundaryIs")->at("coordinates");$f=$_->at("SimpleData[name=\"COUNTYFP\"]"); $s=$_->at("SimpleData[name=\"STATEFP\"]"); $n=$_->at("SimpleData[name=\"NAME\"]"); join("\t",$s->text.$f->text,$n->text,$c->text )})->join("\n")' > $state.cord

# merge coords with style from smokymountains.com
Rscript -e "f<-read.table('$fallweekfile',sep=',',quote=''); m<-read.table('$state.coord',sep='\t',quote=''); a<-merge(f,m,by='V1',all=F); write.table(a,file='$state.stylecord',row.names=F,col.names=F,sep='\t',quote=F)" 

## header of kml
cat <<HEREDOC
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:atom="http://www.w3.org/2005/Atom" xmlns="http://www.opengis.net/kml/2.2">
<Document>
<name>state $state</name>
<visibility>1</visibility>
HEREDOC

## styles for each color
colors=( 0IDXisNA 83A87C FCF6B4 FECC5C F68C3F EF3D23 BD2029 983720)
for i in $(seq 1 $[${#colors[@]}-1]); do
   rgb=${colors[$i]}
   # kml is backwards, plus we need alpha (first)
   abgr=88${rgb:4:5}${rgb:2:2}${rgb:0:2}
   cat <<HEREDOC
   <Style id="f$i">
      <PolyStyle> <color>$abgr</color> </PolyStyle>
      <LineStyle>
         <color>ffffffff</color>
         <width>1</width>
      </LineStyle>
   </Style>
HEREDOC
done

cat <<HEREDOC
<Folder id="$state leaves">
 <name>leaves</name>
HEREDOC


## for each place
#join -j1 <(sed 's/,/\t/g' ~/foliage_20171015.csv|sort) <(cut -f1-3 -s -d$'\t' pa.coord|sort) | 
cat $state.stylecord |
 while IFS=$'\t' read fips style name coord; do
 cat <<HEREDOC
 <Placemark id="$name$fips">
    <name>$name - $fips</name>
    <visibility>1</visibility>
    <styleUrl>#$style</styleUrl>
    <Polygon>
        <extrude>0</extrude>
        <tessellate>1</tessellate>
        <altitudeMode>clampToGround</altitudeMode>
        <outerBoundaryIs>
           <LinearRing>
              <coordinates>$coord</coordinates>
           </LinearRing>
        </outerBoundaryIs>
     </Polygon>
 </Placemark>
HEREDOC
done

# FINISH kml
echo "
</Folder>
</Document></kml>
"
