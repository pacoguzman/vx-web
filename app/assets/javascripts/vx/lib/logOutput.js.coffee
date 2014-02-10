root = global ? window
root.VxLib ||= {}

class root.VxLib.LogOutput

  constructor: (collection, callback) ->
    @collection = collection
    @callback   = callback
    @reset()

  reset: () ->
    @positionInCollection = 0
    @lastLineHasNL        = true
    @replace              = false
    @begin                = true

  process: () ->
    if @isCollectionChanged()
      output    = @extractOutput()
      fragments = @extractFragments(output)
      @processFragments(fragments)

  isCollectionChanged: () ->
    @collection && @collection.length && @positionInCollection != @collection.length

  processFragments: (fragments) ->

    if @begin
      @begin = false
      @callback("newline")

    for fragment in fragments
      switch fragment
        when "\n"
          @replace = false
          @callback('newline')
        when "\r"
          @replace = true
        else
          if @replace
            @replace = false
            @callback("replace", fragment)
          else
            @callback("append", fragment)

  extractOutput: () ->
    output = ""
    newLen = @collection.length

    for i in [@positionInCollection..(newLen - 1)]
      output += @collection[i]

    @positionInCollection = newLen
    @normalize output

  extractFragments: (output) ->
    fragments = []
    lines = output.split(/(\n)/)

    if lines.slice(-1)[0] == ""
      lines.pop()

    for line in lines
      if line == "\n"
        fragments.push line
      else
        for chunk in line.split(/(\r)/)
          fragments.push chunk
    fragments

  normalize: (str) ->
    str.replace(/\r\n/g, '\n')
       .replace(/\r\r/g, '\r')
       .replace(/\033\[K\r/g, '\r')
       .replace(/\[2K/g, '')
       .replace(/\033\(B/g, '')
       .replace(/\033\[\d+G/g, '')

