describe "VxLib.LogOutput", ->

  collection = []
  record     = []
  logOutput  = []

  callback   = (mode, line) ->
    if line != undefined
      record.push [mode, line]
    else
      record.push mode

  beforeEach ->
    collection = []
    record     = []
    logOutput  = new VxLib.LogOutput(collection, callback)

  it 'should process strings with \n', ->
    collection.push "line1\n"
    logOutput.process()
    expect(record).toEqual ['newline', ['append', 'line1'], 'newline']

    record.length = 0

    collection.push "line2\n"
    logOutput.process()
    expect(record).toEqual [['append', 'line2'], 'newline']

  it 'should process strings without \n', ->
    collection.push "line1"
    logOutput.process()
    expect(record).toEqual ['newline', ['append', 'line1']]

    record.length = 0

    collection.push "line2\n"
    logOutput.process()
    expect(record).toEqual [['append', 'line2'], 'newline']

    record.length = 0

    collection.push "line3\n"
    logOutput.process()
    expect(record).toEqual [['append', 'line3'], 'newline']

  it 'should process strings with \r', ->
    collection.push "line1"
    logOutput.process()
    expect(record).toEqual ['newline', ['append', "line1"]]

    record.length = 0

    collection.push "\rline2"
    logOutput.process()
    expect(record).toEqual [['append', ''], ['replace', 'line2']]

  it "should skip if not changed", ->
    logOutput.process()
    expect(record).toEqual []

    collection.push "line"
    logOutput.process()
    expect(record).toEqual ['newline', ['append', 'line']]

    record.length = 0

    logOutput.process()
    expect(record).toEqual []

    collection.push "line2"
    logOutput.process()
    expect(record).toEqual [['append', 'line2']]

