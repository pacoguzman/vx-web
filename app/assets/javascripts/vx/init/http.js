var app = angular.module("Vx");

app.config(['$httpProvider',
    function ($httpProvider) {
      var $http,
      interceptor = ['$q', '$injector', '$window', function ($q, $injector, $window) {
          var error;

          function toggle(st) {
            sp = $window.document.getElementById("ajax-loading");
            if (sp) {
              sp.hidden = !sp
            }
          }

          function success(response) {
            // get $http via $injector because of circular dependency problem
            $http = $http || $injector.get('$http');
            if($http.pendingRequests.length < 1) {
              toggle(false);
            }
            return response;
          }

          function error(response) {
            // get $http via $injector because of circular dependency problem
            $http = $http || $injector.get('$http');
            if($http.pendingRequests.length < 1) {
              toggle(false);
            }
            return $q.reject(response);
          }

          return function (promise) {
            toggle(true);
            return promise.then(success, error);
          }
      }];

      $httpProvider.responseInterceptors.push(interceptor);
}]);
