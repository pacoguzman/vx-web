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

      normalize = (str) ->
        str.replace(/\r\n/g, '\n')
           .replace(/\r\r/g, '\r')
           .replace(/\033\[K\r/g, '\r')
           .replace(/\[2K/g, '')
           .replace(/\033\(B/g, '')
           .replace(/\033\[\d+G/g, '')

      extractCurrentOutput = (newLen) ->
        output = ""

        for i in [positionInCollection..(newLen - 1)]
          output += scope.collection[i]

        positionInCollection = newLen
        normalize output

      extractLines = (output) ->
        positionInOutput = 0
        lines = []

        loop
          idx = output.indexOf("\n", positionInOutput)
          idx

          # have new line
          if idx != -1
            lines.push output.substring(positionInOutput, idx + 1)
            positionInOutput = idx + 1
          # end of buffer
          else
            # tail in buffer
            if positionInOutput < output.length
              lines.push output.substring(positionInOutput)
            break

        lines

      addLineToDom = (line) ->
        el = document.createElement("p")
        el.innerHTML = "<a></a>#{line}"

        elem[0].appendChild el
        el

      colorize = (str) ->
        html = ""
        fragments = ansiparse(str)
        for fragment in fragments
          classes = []
          text = if fragment.text == "" then nbsp else fragment.text
          #fragment.bold && classes.push("ansi-bold")
          fragment.foreground && classes.push("ansi-fg-" + fragment.foreground)
          #fragment.background && classes.push("ansi-bg-" + fragment.background)

          if classes.length > 0
            html += "<span class=\"#{classes.join ' '}\">#{text}</span>"
          else
            html += "<span>#{text}</span>"
        html

      lastLineHasNL        = true
      lastChild            = null

      updateLines = (newLen, oldLen) ->
        return if _.isUndefined(newLen)

        elem.removeClass("hidden")

        return if newLen == 0

        #  was truncated
        if positionInCollection > newLen
          elem[0].innerHTML = ""

        output = extractCurrentOutput(newLen)
        lines  = extractLines(output)

        idx = 0
        for line in lines
          mode = 'newline'

          # replace existing
          rep = line.lastIndexOf("\r")
          if rep != -1
            mode = 'replace'
            line = line.substring(rep + 1)

          line = colorize(line)

          if idx == 0 and !lastLineHasNL
            if mode == 'replace'
              lastChild.innerHTML = "<a></a>#{line}"
            else
              lastChild.innerHTML = lastChild.innerHTML + line
          else
            lastChild = addLineToDom(line)
          idx += 1

        if _.last(lines).indexOf("\n") != -1
          lastLineHasNL = true
        else
          lastLineHasNL = false

      elem.addClass("hidden")

      scope.$watch('collection.length', updateLines)
