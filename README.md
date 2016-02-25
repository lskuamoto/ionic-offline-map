Aplicativo para acesso offline de mapas desenvolvido em IONIC + LeafLet (Até o momento foi testado apenas para Android!).

O aplicativo importa um arquivo '.mbtiles' exportado pelo TileMill (https://www.mapbox.com/tilemill/) em um banco Sqlite e acessa ele através do LeafLet.

Tem uma referência boa sobre como exportar os tiles no TileMill (https://www.e-education.psu.edu/geog585/node/711).

No TileMill foram importados os arquivos geográficos de Porto Alegre, disponíveis em http://metro.teczno.com/#porto-alegre e se aplicou um CartoCSS (https://www.mapbox.com/tilemill/docs/manual/carto/) para que ficasse parecido com o OpenStreetMap(www.openstreetmap.org).

O arquivo '.mbtiles' está na pasta 'www', e é copiado para a pasta destino de cada plataforma utilizando-se do plugin 'Cordova-plugin-dbcopy'.

Utiliza os plugins:
- cordova-sqlite-storage (https://github.com/litehelpers/Cordova-sqlite-storage)
> cordova plugin add https://github.com/litehelpers/Cordova-sqlite-storage

- cordova-plugin-dbcopy (https://github.com/an-rahulpandey/cordova-plugin-dbcopy)
> cordova plugin add https://github.com/an-rahulpandey/cordova-plugin-dbcopy.git

- cordova-plugin-geolocation (https://github.com/apache/cordova-plugin-geolocation)
> cordova plugin add cordova-plugin-geolocation

- cordova-plugin-crosswalk-webview (https://github.com/crosswalk-project/cordova-plugin-crosswalk-webview)
> cordova plugin add cordova-plugin-crosswalk-webview

Foi baseado nos seguintes projetos/referências:

- http://sebastian-meier.github.io/OfflineMaps/index.html
- http://geospatialscott.blogspot.com.br/2012/04/phonegap-leaflet-tilemill-offline.html
- https://github.com/calendee/ionic-leafletjs-map-demo
