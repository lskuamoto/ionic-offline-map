angular.module('starter.controllers', [])

.controller('MapCtrl', function($scope, $rootScope, $cordovaSQLite, $cordovaGeolocation, $ionicModal, $ionicPopup, $ionicPlatform, SqliteService, mapDbName) {

//////////////////
/**
var queryResult = SqliteService.query("SELECT tile_data FROM images INNER JOIN map ON images.tile_id = map.tile_id");

queryResult.then(function(res) {
  console.log('queryResult: ' + res);
});
**/
//////////////




  console.log("MapCtrl mapDbName: " + mapDbName);

  // layer marker de posição
  $scope.layerPositionMarker = null;







  if (window.sqlitePlugin) {
      console.log('has sqlitePlugin');

      $scope.copysuccess = function () {
        console.log("copy success");
        $scope.buildMap();

      };

      $scope.copyerror = function (e) {
        //db already exists or problem in copying the db file. Check the Log.
        console.log("Error Code = "+JSON.stringify(e));
        //e.code = 516 => if db exists
        if (e.code == 516) {
            console.log('removing existent database file..new copy');
            window.plugins.sqlDB.remove(mapDbName, 0, $scope.removesuccess, $scope.removeerror);          }
      };

      $scope.removesuccess = function () {
        console.log("remove success");
        window.plugins.sqlDB.copy(mapDbName, 0, $scope.copysuccess, $scope.copyerror);
      };

      $scope.removeerror = function () {
        console.log("remove error");
      };

      window.plugins.sqlDB.copy(mapDbName,  0, $scope.copysuccess, $scope.copyerror);
  }

 
  $scope.buildMap = function() {
   console.log("build map");

   var dbOptions = {};

   if (ionic.Platform.isAndroid()) {
     dbOptions = {name: mapDbName, createFromLocation: 1, location: 'default', androidDatabaseImplementation: 2, androidLockWorkaround: 1};
   }
   else {
     dbOptions = {name: mapDbName, createFromLocation: 1};
   }

   var db = window.sqlitePlugin.openDatabase(dbOptions, function(db) {
     db.transaction(function(tx) {
       console.log("transaction: " + tx);
       $scope.map = new L.Map('map', {
         center: new L.LatLng(-30.036286, -51.220186),
         attributionControl: true,
         zoom: 14,
         maxZoom: 17,
         minZoom: 12,
         maxBounds: new L.LatLngBounds(new L.LatLng(-30.1876, -51.1003), //southWest
                                       new L.LatLng(-29.9651, -51.2692) // northEast
                                     )
       });

       var lyr = new L.TileLayer.MBTiles('',
          {
           tms: true,
           scheme: 'tms',
           unloadInvisibleTiles:true
         },  db);

       lyr.addTo($scope.map);

       console.log("end of build map");
     }, function(err) {
       console.log('Open database ERROR: ' + JSON.stringify(err));
     });
   });

  };

  /**
   * Center map on user's current position
   */
  $scope.locate = function(){

    $cordovaGeolocation
      .getCurrentPosition()
      .then(function (position) {
        console.log('current position: '+position);

        // remove layer que contém markers de posição
        if ($scope.layerPositionMarker != null) {
          $scope.map.removeLayer($scope.layerPositionMarker);
        }

        $scope.map.setView(new L.LatLng(position.coords.latitude, position.coords.longitude), 17, {animate: true});

        var marker = L.marker([position.coords.latitude,position.coords.longitude]).bindPopup("<b>Estou aqui</b>").openPopup();

        $scope.layerPositionMarker = L.layerGroup([marker]);
        $scope.layerPositionMarker.addTo($scope.map);

      }, function(err) {
        // error
        console.log("Location error!");
        console.log(err);
      });

  };
});
