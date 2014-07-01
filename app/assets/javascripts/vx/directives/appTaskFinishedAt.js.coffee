angular.module('Vx').
  directive "appTaskFinishedAt", () ->

    restrict: 'EC'
    replace: true
    scope: {
      task: "=task"
    }

    link: (scope, elem, attrs) ->

      updateFinishedAt = (newVal, _) ->
        if newVal
          val = moment(newVal).fromNow()
          elem.text(val)
        else
          elem.text("- : -")

      scope.$watch('task.finished_at', updateFinishedAt)
