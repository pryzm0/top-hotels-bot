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
        var list = $scope.config.robot.target.hotels;
        if (list.indexOf(id) === -1) {
          list.push(m ? m[1] : $scope.hotelInput);
        }
        else {
          alert('already added');
        }
      };

      $scope.removeHotel = function (index) {
        $scope.config.robot.target.hotels.splice(index, 1);
      };
    })
    .controller('RobotController', function ($scope, Api) {
      $scope.logtail = '';

      $scope.run = function () {
        $('body').css('cursor', 'wait');
        Api.runRobot().then(function (stdout) {
          $scope.logtail = stdout;
        }).finally(function () {
          $('body').css('cursor', '');
        });
      };
    })
    .controller('MailerController', function ($scope, Api) {
      $scope.logtail = '';

      $scope.run = function () {
        $('body').css('cursor', 'wait');
        Api.runMailer().then(function (stdout) {
          $scope.logtail = stdout;
        }).finally(function () {
          $('body').css('cursor', '');
        });
      };
    })
    .service('Api', function ($http) {
      return {
        getConfig: function () {
          return $http.get('/api/config').then(responseData);
        },

        setConfig: function (data) {
          return $http.post('/api/config', data).then(responseData);
        },

        getRobotLog: function () {
          return $http.get('/api/robot').then(responseData);
        },

        runRobot: function () {
          return $http.post('/api/robot', {}).then(responseData);
        },

        getMailerLog: function () {
          return $http.get('/api/mailer').then(responseData);
        },

        runMailer: function () {
          return $http.post('/api/mailer', {}).then(responseData);
        },
      };

      function responseData(response) {
        return response.data;
      }
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
