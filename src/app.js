(function() {
    var mod = angular.module('app', ['ngRoute']);

    mod.config(['$routeProvider', function($routeProvider) {
        $routeProvider.when('/', {
            templateUrl: 'pages/profile.html'
        }).when('/career', {
            templateUrl: 'pages/career.html'
        }).when('/projects', {
            templateUrl: 'pages/projects.html'
        }).otherwise({
            redirectTo: '/'
        });
    }]);

    mod.controller('AppCtrl', ['$scope', '$route', '$http', function($scope, $route, $http) {
        $http.get('/i18n/model-en.json').success(function(model) {
            angular.extend($scope, model);
            $route.reload();
        });
    }]);
})();
