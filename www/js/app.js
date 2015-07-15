(function () {
  'use strict';

  angular.module('BotUI', ['ngRoute'])
    .controller('ConfigController', function ($scope, Api) {
      Api.getConfig().then(function (config) {
        $scope.config = config;
      });

      $scope.hotelInput = '';

      $scope.save = function () {
        Api.setConfig($scope.config).then(function () {
          alert('CONFIG SAVED');
        });
      };

      $scope.addHotel = function () {
        var m = $scope.hotelInput.match(/\/main\/hotel\/(\w+)/);
        var id = m ? m[1] : $scope.hotelInput;
        if ($scope.config.hotels.indexOf(id) === -1) {
          $scope.config.hotels.push(m ? m[1] : $scope.hotelInput);
        }
        else {
          alert('already exists');
        }
      };

      $scope.removeHotel = function (index) {
        $scope.config.hotels.splice(index, 1);
      };
    })
    .controller('RobotController', function ($scope, Api) {
      $scope.log = [];

      readLog();

      $scope.run = function () {
        $('body').css('cursor', 'wait');
        Api.runRobot().then(function () {
          return readLog();
        }).finally(function () {
          $('body').css('cursor', '');
        });
      };

      function readLog() {
        Api.getRobotLog().then(function (data) {
          $scope.log = data;
        });
      }
    })
    .controller('MailerController', function ($scope, Api) {
      $scope.log = [];

      readLog();

      $scope.run = function () {
        $('body').css('cursor', 'wait');
        Api.runMailer().then(function () {
          return readLog();
        }).finally(function () {
          $('body').css('cursor', '');
        });
      };

      function readLog() {
        Api.getMailerLog().then(function (data) {
          $scope.log = data;
        });
      }
    })
    .service('Api', function ($http) {
      return {
        getConfig: function () {
          return $http.get('/api/config').then(function (response) {
            return response.data;
          });
        },

        setConfig: function (data) {
          return $http.post('/api/config', data).then(function (response) {
            return true;
          });
        },

        getRobotLog: function () {
          return $http.get('/api/robot').then(function (response) {
            return response.data;
          });
        },

        runRobot: function () {
          return $http.post('/api/robot', {}).then(function () {
            return true;
          });
        },

        getMailerLog: function () {
          return $http.get('/api/mailer').then(function (response) {
            return response.data;
          });
        },

        runMailer: function () {
          return $http.post('/api/mailer', {}).then(function (response) {
            return true;
          });
        },
      };
    })
    .filter('bunyan', function () {
      return function (obj) {
        var lines = [];
        for (var key in obj) {
          if (!obj.hasOwnProperty(key)) {
            continue;
          }
          if (key.charAt(0) === '$') {
            continue;
          }
          if (key === 'hostname' || key === 'pid' || key === 'v' || key === 'level') {
            continue;
          }
          lines.push('' + key + ': ' + obj[key]);
        }
        return lines.join('\n');
      };
    })
    .config(function ($routeProvider, $locationProvider) {
      $routeProvider
        .when('/config', {
          templateUrl: 'config.html',
          controller: 'ConfigController',
        })
        .when('/robot', {
          templateUrl: 'robot.html',
          controller: 'RobotController',
        })
        .when('/mailer', {
          templateUrl: 'mailer.html',
          controller: 'MailerController',
        });

      // $locationProvider.html5Mode(true);
    });

}());
