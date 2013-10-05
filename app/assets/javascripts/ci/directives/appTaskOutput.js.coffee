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
      nbsp = '\u00A0'

      updateLines = (newVal) ->
        return unless newVal

        unsorted = []
        container = document.createElement("div")

        _.each newVal, (it) ->
          unsorted.push it

        scope.lines = _.sortBy unsorted, (it) ->
          it.tm

        output = _.map(scope.lines, (it) -> it.data).join("").split("\n")

        _.each output, (it, idx) ->
          line = if it == "" then nbsp else it

          numEl = document.createElement("a")
          numEl.className = 'app-tack-output-line-number'
          numEl.href = "#L#{idx + 1}"

          txtEl = document.createElement("span")
          txtEl.appendChild document.createTextNode(line)

          lineEl = document.createElement("div")
          lineEl.className = "app-task-output-line"

          lineEl.appendChild numEl
          lineEl.appendChild txtEl

          container.appendChild(lineEl)

        elem.html container.innerHTML

      scope.$watch('collection', updateLines, true)
