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

    mod.controller('AppCtrl', ['$scope', '$route', '$http', '$timeout', function($scope, $route, $http, $timeout) {
        var langKey = 'lang';
        $scope.languages = {
            en: 'English',
            ru: 'Русский'
        };
        $scope.setLang = function(lang) {
            $scope.lang = lang;
            $scope.loading = lang === 'ru' ? 'Загрузка...' : 'Loading...';
            $scope.language = $scope.languages[lang];
            $http.get('/i18n/model-' + lang + '.json').success(function(model) {
                $timeout(function() {
                    angular.extend($scope, model);
                    $scope.loading = null;
                    localStorage[langKey] = lang;
                }, 2000);
            });
        };
        $scope.setLang(localStorage[langKey] || navigator.language || 'en');
    }]);
})();
