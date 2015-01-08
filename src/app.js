(function() {
    var mod = angular.module('app', ['ngAnimate', 'ngRoute', 'angularMoment']);

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

    mod.controller('AppCtrl', ['$scope', '$route', '$http', '$timeout', 'amMoment', function($scope, $route, $http, $timeout, amMoment) {
        var langKey = 'lang';
        $scope.languages = {
            en: 'English',
            ru: 'Русский'
        };
        $scope.setLang = function(lang) {
            $scope.$root.lang = lang;
            $scope.loading = lang === 'ru' ? 'Загрузка...' : 'Loading...';
            $scope.language = $scope.languages[lang];
            amMoment.changeLocale(lang);
            $http.get('/i18n/model-' + lang + '.json').success(function(model) {
                // convert ISO dates to JavaScript Date
                (function convertDates(obj) {
                    angular.forEach(obj, function(value, key) {
                        if (angular.isObject(value)) {
                            convertDates(value);
                        } else if (/Date$/.test(key)) {
                            obj[key] = new Date(value);
                        }
                    });
                })(model);

                // convert specific objects to arrays
                model.jobs = $.map(model.jobs, function(job) {
                    job.projects = $.map(job.projects, function(project) {
                        return project;
                    });
                    return job;
                });

                model.workExperienceYears = model.jobs.reduce(function(sum, job) {
                    return sum + moment(job.toDate).diff(job.fromDate, 'years', true);
                }, 0);

                model.ageYears = moment().diff(model.birthdayDate, 'years', true);

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

    mod.filter('capitalize', function() {
        return function(value) {
            return value && angular.isString(value) ? value[0].toUpperCase() + value.substr(1) : value;
        };
    });

    mod.filter('fixed', ['$rootScope', function($rootScope) {
        return function(value, fractionDigits) {
            var point = $rootScope.lang === 'ru' ? ',' : '.';
            return angular.isNumber(value) ? value.toFixed(fractionDigits).replace('.', point) : value;
        };
    }]);
})();
