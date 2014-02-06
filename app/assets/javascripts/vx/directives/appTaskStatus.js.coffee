angular.module('Vx').
  directive "appTaskStatus", ($compile) ->

    restrict: 'EC'
    transclude: true
    scope: {
      task: "=task",
    }

    compile: (tElem, tAttrs, transclude) ->
      ($scope, elem, attrs) ->

        updateTaskStatus = (newVal, _) ->
          if newVal
            elem.removeClass("task-status-#{$scope.prevClass}") if $scope.prevClass
            elem.addClass("task-status-#{newVal}")
            $scope.prevClass = newVal

        transclude $scope, (clone) ->
          elem.append(clone)
          elem.prepend('<i class="fa fa-circle">')
          $scope.$watch "task.status", updateTaskStatus
