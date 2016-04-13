Offline map mobile app using IONIC + LeafLet (it was tested only for Android!).

The app imports a '.mbtiles' file exported using TileMill (https://www.mapbox.com/tilemill/) to a Sqlite Database.

You cant get a good tutorial of how to export the tiles in https://www.e-education.psu.edu/geog585/node/711.

In this project I'd used the geo files from Porto Alegre / Brazil available in http://metro.teczno.com/#porto-alegre , and I'd applied a CartoCSS (https://www.mapbox.com/tilemill/docs/manual/carto/) to look like OpenStreetMap(www.openstreetmap.org).

The '.mbtiles' i stored in 'www' folded, and it is copied to the correct folder for each platform using the plugin 'Cordova-plugin-dbcopy'.

Using the following plugins:
- cordova-sqlite-storage (https://github.com/litehelpers/Cordova-sqlite-storage)
> cordova plugin add https://github.com/litehelpers/Cordova-sqlite-storage

- cordova-plugin-dbcopy (https://github.com/an-rahulpandey/cordova-plugin-dbcopy)
> cordova plugin add https://github.com/an-rahulpandey/cordova-plugin-dbcopy.git

- cordova-plugin-geolocation (https://github.com/apache/cordova-plugin-geolocation)
> cordova plugin add cordova-plugin-geolocation

- cordova-plugin-crosswalk-webview (https://github.com/crosswalk-project/cordova-plugin-crosswalk-webview)
> cordova plugin add cordova-plugin-crosswalk-webview

Based on the following references:

- http://sebastian-meier.github.io/OfflineMaps/index.html
- http://geospatialscott.blogspot.com.br/2012/04/phonegap-leaflet-tilemill-offline.html
- https://github.com/calendee/ionic-leafletjs-map-demo
