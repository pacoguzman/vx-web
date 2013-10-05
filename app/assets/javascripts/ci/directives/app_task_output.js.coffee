angular.module('CI').
  directive "appTaskOutput", () ->

    restrict: 'EC'
    replace: true
    scope: {
      collection: "=collection",
    }

    template:
      '<div></div>'

    link: (scope, elem, attrs) ->
      scope.lines = []
      scope.output = ""

      updateLines = (newVal, oldVal) ->
        unsorted = []
        container = document.createElement("div")

        _.each newVal, (it) ->
          unsorted.push it

        scope.lines = _.sortBy unsorted, (it) ->
          it.tm

        output = _.map(scope.lines, (it) -> it.data).join("").split("\n")

        _.each output, (it, idx) ->
          nbsp = '\u00A0'
          line = if it == "" then nbsp else it.replace(/\ /g, nbsp)
          log = document.createElement("div")
          log.className = "app-task-output-line"
          logLine = document.createTextNode(line)
          log.appendChild(logLine)
          container.appendChild(log)

        elem.html container.innerHTML

      scope.$watch('collection', updateLines, true)
