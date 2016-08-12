angular.module('starter.services')
// Service ainda em testes...tentativa de criar o DB só uma vez numa factory service
.factory('SqliteService',function($q, $cordovaSQLite, $ionicPlatform, mapDbName){
  var self = this;
  self.db = null;
  self.dbPromise = null;

  self.copysuccess = function () {
    console.log("copy success");
    $scope.buildMap();
  };

  self.copyerror = function (e) {
    //db already exists or problem in copying the db file. Check the Log.
    console.log("Error Code = "+JSON.stringify(e));
    //e.code = 516 => if db exists
    if (e.code == 516) {
        console.log('removing existent database file..new copy');
        window.plugins.sqlDB.remove(mapDbName, 0, removesuccess, removeerror);          }
  };

  self.removesuccess = function () {
    console.log("remove success");
    window.plugins.sqlDB.copy(mapDbName, 0, copysuccess, copyerror);
  };

  self.removeerror = function () {
    console.log("remove error");
  };

  self.openDataBase = function (def) {
    var dbOptions = {};

    if (ionic.Platform.isAndroid()) {
      dbOptions = {name: mapDbName, createFromLocation: 1, androidDatabaseImplementation: 2, androidLockWorkaround: 1};
    }
    else {
      dbOptions = {name: mapDbName, createFromLocation: 1};
    }

    self.db = window.sqlitePlugin.openDatabase(dbOptions, function(){
      def.resolve(true);
      console.log('opened def = true');
    });
  };

  self.init = function() {
      console.log("sqlservice init");
      var def = $q.defer();
      if (self.db != null) {
        console.log('database already created');
        return self.dbPromise;
      }
      else {
        try {
          if (window.sqlitePlugin) {
            var dbOptions = {};

            if (ionic.Platform.isAndroid()) {
              dbOptions = {name: mapDbName, createFromLocation: 1, androidDatabaseImplementation: 2, androidLockWorkaround: 1};
            }
            else {
              dbOptions = {name: mapDbName, createFromLocation: 1};
            }

            self.db = window.sqlitePlugin.openDatabase(dbOptions, function(){
              def.resolve(true);
              console.log('opened def = true');
            });

        } else {
          def.reject();
        }
      } catch (e) {
        def.reject(e);
      }
    }
    self.dbPromise = def.promise; // salva a promise de abertura do bd

    return def.promise;
  };

self.query = function(query, bindings) {
  self.dbPromise = self.init();
  //do stuff to the database. use promises
  bindings = typeof bindings !== 'undefined' ? bindings : [];
  var execQueryDef = $q.defer();

  self.dbPromise.then(function(query, bindings) {
    self.db.transaction(function(transaction) {
        transaction.executeSql(query, bindings,function(trans,resp){
            execQueryDef.resolve(resp);
        });
    });
  });

  return execQueryDef.promise;
}

return self;
});
