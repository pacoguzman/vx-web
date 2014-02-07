describe "VxLib.LogOutput", ->

  collection = []
  record     = []
  logOutput  = []

  callback   = (mode, line) ->
    record.push [mode, line]

  beforeEach ->
    collection = []
    record     = []
    logOutput  = new VxLib.LogOutput(collection, callback)

  it 'should process strings with \n', ->
    collection.push "line1\n"
    logOutput.process()
    expect(record).toEqual [['newline', "line1\n"]]

    collection.push "line2\n"
    logOutput.process()
    expect(record).toEqual [['newline', "line1\n"], ['newline', "line2\n"]]

  it 'should process strings without \n', ->
    collection.push "line1"
    logOutput.process()
    expect(record).toEqual [['newline', "line1"]]

    collection.push "line2\n"
    logOutput.process()
    expect(record).toEqual [['newline', "line1"], ['append', "line2\n"]]

    collection.push "line3\n"
    logOutput.process()
    expect(record).toEqual [['newline', "line1"], ['append', "line2\n"], ['newline', "line3\n"]]

  it 'should process strings with \r', ->
    collection.push "line1"
    logOutput.process()
    expect(record).toEqual [['newline', "line1"]]

    collection.push "\rline2"
    logOutput.process()
    expect(record).toEqual [['newline', "line1"], ['replace', "line2"]]

  it "should skip if not changed", ->
    logOutput.process()
    expect(record).toEqual []

    collection.push "line"
    logOutput.process()
    expect(record).toEqual [['newline', 'line']]

    logOutput.process()
    expect(record).toEqual [['newline', 'line']]

    collection.push "line2"
    logOutput.process()
    expect(record).toEqual [['newline', 'line'], ['append', 'line2']]
