describe "Bashboard", ->

  beforeEach ->
    browser.get('http://127.0.0.1:9000/');

  beforeEach ->
    browser.get('/ui');

  it "should be", ->
    console.log 1
