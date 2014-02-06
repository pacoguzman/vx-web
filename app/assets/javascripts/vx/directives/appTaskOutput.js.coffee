angular.module('Vx').
  directive "appTaskOutput", ($window) ->

    restrict: 'EC'
    replace: true
    scope: {
      collection: "=collection",
    }

    template:
      '<div></div>'

    link: (scope, elem, attrs) ->
      nbsp = '\u00A0'

      positionInCollection = 0

      extractCurrentOutput = (newLen) ->
        output = ""

        for i in [positionInCollection..(newLen - 1)]
          output += scope.collection[i].data

        positionInCollection = newLen
        output

      extractLines = (output) ->
        positionInOutput = 0
        lines = []

        loop
          idx = output.indexOf("\n", positionInOutput)
          idx += 1

          # have new line
          if idx > 0
            lines.push output.substring(positionInOutput, idx)
            positionInOutput = idx
          # end of buffer
          else
            # tail in buffer
            if positionInOutput < output.length
              lines.push output.substring(positionInOutput)
            break

        lines

      addLineToDom = (line) ->
        numEl = document.createElement("a")
        numEl.className = 'app-tack-output-line-number'

        textEl = document.createElement("span")
        textEl.appendChild document.createTextNode(if line == "" then nbsp else line)

        lineEl = document.createElement("div")
        lineEl.className = "app-task-output-line"

        lineEl.appendChild numEl
        lineEl.appendChild textEl

        elem[0].appendChild lineEl
        textEl

      lastLineHasNL        = true
      lastChild            = null

      updateLines = (newLen, oldLen) ->
        return if _.isUndefined(newLen) || newLen == 0

        #  was truncated
        if positionInCollection > newLen
          elem[0].innerHTML = ""

        elem.removeClass("hidden")

        output = extractCurrentOutput(newLen)
        lines  = extractLines(output)

        idx = 0
        for line in lines
          if idx == 0 and !lastLineHasNL
            lastChild.innerHTML = lastChild.innerHTML + line
          else
            lastChild = addLineToDom(line)
          idx += 1

        if _.last(lines).indexOf("\n") >= 0
          lastLineHasNL = true
        else
          lastLineHasNL = false

      elem.addClass("hidden")

      scope.$watch('collection.length', updateLines)
