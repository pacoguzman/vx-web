angular.module('Vx').
  directive "appTaskStatusClass", () ->

    restrict: 'EC'
    replace: false
    scope: true

    link: (scope, elem, attrs) ->

      updateTaskStatusClass = (newVal, _) ->
        if newVal
          elem.removeClass("task-status-#{scope.prevClass}") if scope.prevClass
          elem.addClass("task-status-#{newVal}")
          scope.prevClass = newVal

      status = elem.attr("status")
      scope.$watch(status, updateTaskStatusClass)
