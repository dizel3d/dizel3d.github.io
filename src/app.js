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
                model.job = $.map(model.jobs, function(job) {
                    job.projects = $.map(job.projects, function(project) {
                        return project;
                    });
                    return job;
                });
                angular.extend($scope, model);
                $scope.loading = null;
                localStorage[langKey] = lang;
            });
        };
        $scope.setLang(localStorage[langKey] || navigator.language || 'en');
    }]);

    mod.controller('NavCtrl', ['$scope', '$location', function($scope, $location) {
        function Nav(url, title) {
            this.url = url;
            this.title = title;
        }
        Nav.prototype.isActive = function() {
            return $location.path() === this.url;
        };

        $scope.navs = [
            new Nav('/', $scope.navs.profile),
            new Nav('/career', $scope.navs.career),
            new Nav('/projects', $scope.navs.projects)
        ]
    }]);
})();
