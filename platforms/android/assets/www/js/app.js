// Ionic Starter App
// angular.module is a global place for creating, registering and retrieving Angular modules
// 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
// the 2nd parameter is an array of 'requires'
// 'starter.services' is found in services.js
// 'starter.controllers' is found in controllers.js
//angular.module('starter', [ 'ionic','ngCordova','leaflet-directive', 'starter.controllers', 'starter.services', 'igTruncate'])
angular.module('starter', [ 'ionic','ngCordova', 'starter.controllers', 'starter.services'])
.run(function($ionicPlatform, $cordovaSQLite, $rootScope, SqliteService) {


  $ionicPlatform.ready(function() {
    // Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    // for form inputs)
    $rootScope.readyToDb = false;
    if (window.cordova && window.cordova.plugins && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      cordova.plugins.Keyboard.disableScroll(true);

    }
    if (window.StatusBar) {
      // org.apache.cordova.statusbar required
      StatusBar.styleDefault();
    }

    //SqliteService.init();
  });
})

.config(function($stateProvider, $urlRouterProvider) {

  // Ionic uses AngularUI Router which uses the concept of states
  // Learn more here: https://github.com/angular-ui/ui-router
  // Set up the various states which the app can be in.
  // Each state's controller can be found in controllers.js
  $stateProvider

  // setup an abstract state for the tabs directive
    .state('tab', {
    url: '/tab',
    abstract: true,
    templateUrl: 'templates/tabs.html'
  })

  // Each tab has its own nav history stack:

  .state('tab.map', {
    url: '/map',
    views: {
      'tab-map': {
        templateUrl: 'templates/tab-map.html',
        controller: 'MapCtrl',
        resolve: {
                  cordova: function($q) {
                      var deferred = $q.defer();
                      ionic.Platform.ready(function() {
                          console.log('ionic.Platform.ready');
                          
                          
cordova.plugins.diagnostic.requestRuntimePermissions(function(statuses){
    for (var permission in statuses){
        switch(statuses[permission]){
            case cordova.plugins.diagnostic.permissionStatus.GRANTED:
                console.log("Permission granted to use "+permission);
                break;
            case cordova.plugins.diagnostic.permissionStatus.NOT_REQUESTED:
                console.log("Permission to use "+permission+" has not been requested yet");
                break;
            case cordova.plugins.diagnostic.permissionStatus.DENIED:
                console.log("Permission denied to use "+permission+" - ask again?");
                break;
            case cordova.plugins.diagnostic.permissionStatus.DENIED_ALWAYS:
                console.log("Permission permanently denied to use "+permission+" - guess we won't be using it then!");
                break;
        }
    }
    deferred.resolve();
}, function(error){
    console.error("The following error occurred: "+error);
},[
    cordova.plugins.diagnostic.runtimePermission.ACCESS_FINE_LOCATION,
    cordova.plugins.diagnostic.runtimePermission.ACCESS_COARSE_LOCATION,
    cordova.plugins.diagnostic.runtimePermission.WRITE_EXTERNAL_STORAGE,
    cordova.plugins.diagnostic.runtimePermission.READ_EXTERNAL_STORAGE
]);                        
                          



                                            
                          
                      });
                      return deferred.promise;
                  }        
              }        
      }
    }
  })

  .state('tab.chats', {
      url: '/chats',
      views: {
        'tab-chats': {
          templateUrl: 'templates/tab-chats.html',
          controller: 'ChatsCtrl'
        }
      }
    })
    .state('tab.chat-detail', {
      url: '/chats/:chatId',
      views: {
        'tab-chats': {
          templateUrl: 'templates/chat-detail.html',
          controller: 'ChatDetailCtrl'
        }
      }
    })

  .state('tab.account', {
    url: '/account',
    views: {
      'tab-account': {
        templateUrl: 'templates/tab-account.html',
        controller: 'AccountCtrl'
      }
    }
  });

  // if none of the above states are matched, use this as the fallback
  $urlRouterProvider.otherwise('/tab/map');

});
