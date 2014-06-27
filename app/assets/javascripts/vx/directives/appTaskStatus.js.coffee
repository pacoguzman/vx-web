angular.module('Vx').
  directive "appTaskStatus", ['$compile',
    ($compile) ->

      restrict: 'EC'
      scope: {
        task: "=task",
      }

      compile: (tElem, tAttrs, transclude) ->
        ($scope, elem, attrs) ->

          statusName = (s) ->
            switch s
              when 'initialized'
                'pending'
              else
                s

          statusClass = (s) ->
            switch s
              when'deploying', 'started'
                'label-warning-light'
              when 'errored', 'failed'
                'label-danger'
              when 'passed'
                'label-info'
              else
                ''
          map =
            "initialized": "pending"

          updateTaskStatus = (newVal, _) ->
            if newVal
              cls = statusClass(newVal)
              elem.removeClass($scope.prevClass) if $scope.prevClass
              elem.addClass(cls)
              elem.html(statusName(newVal))
              $scope.prevClass = cls

          elem.addClass("label")
          $scope.$watch "task.status", updateTaskStatus, true

    ]
