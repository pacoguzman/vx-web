angular.module('CI').
  directive "appTaskStatus", () ->

    restrict: 'EC'
    replace: false
    scope: {
      task: "=task",
    }

    link: (scope, elem, attrs) ->

      updateTaskStatus = (newVal, _) ->
        if newVal
          elem.removeClass("task-status-#{scope.prevClass}") if scope.prevClass
          elem.addClass("task-status-#{newVal}")
          scope.prevClass = newVal

      scope.$watch("task.status", updateTaskStatus)
      elem.prepend('<i class="icon-circle">')
