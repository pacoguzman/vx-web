angular.module('Vx').
  directive "appTaskDuration", ['$timeout',
    ($timeout) ->

      restrict: 'EC'
      replace: true
      scope: {
        task: "=task",
      }

      link: (scope, elem, attrs) ->

        displayDuration = (st, fn) ->
          diff = moment.duration(fn.diff(st))
          val  = moment(diff.asMilliseconds()).format("mm:ss")
          elem.text val

        progressDuration = () ->
          unless scope.task.finished_at
            st = moment(scope.task.started_at)
            fn = moment()
            displayDuration st, fn
            $timeout(progressDuration, 1000)

        updateDuration = (newVal, _) ->
          return unless newVal

          if newVal.finished_at && newVal.started_at
            st = moment(newVal.started_at)
            fn = moment(newVal.finished_at)
            displayDuration st, fn
          else
            if newVal.started_at
              progressDuration()
            else
              elem.text "- : -"

        scope.$watch('task', updateDuration, true)

  ]


