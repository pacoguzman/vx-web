describe 'buildModel', ->

  $scope     = null
  $http      = null
  build      = null
  buildsJson = null
  usersJson  = null

  resolve = (options, fn) ->
    rs = null
    fn().then (data) ->
      rs = data
    $http.flush() if options.flush
    $scope.$digest()
    rs

  beforeEach ->
    module('Vx', 'Vx.mocks.builds', 'Vx.mocks.users')

    inject ($injector, $rootScope, buildsJSON, usersJSON) ->
      $scope = $rootScope
      $http  = $injector.get("$httpBackend")
      build  = $injector.get("buildModel")
      buildsJson = buildsJSON
      usersJson  = usersJSON

  it "should find all builds in project", ->
    $http.expectGET('/api/projects/1/builds').respond(buildsJson.all)

    expect(resolve(flush: true, () -> build.all('1'))).toEqual buildsJson.all

  it "should find more builds", ->
    $http.expectGET('/api/projects/1/builds').respond(buildsJson.all)
    col = resolve(flush: true, () -> build.all('1'))
    expect(col).toEqual buildsJson.all

    $http.expectGET('/api/projects/1/builds?from=27').respond(buildsJson.all)
    resolve(flush: true, () -> build.loadMore('1'))
    expect(col).toEqual buildsJson.all.concat(buildsJson.all)

  it "should find one build", ->
    $http.expectGET('/api/builds/1').respond(buildsJson.one)

    expect(resolve(flush: true, () -> build.one('1'))).toEqual buildsJson.one

  it "should restart build", ->
    one = buildsJson.one
    restarted = angular.copy one
    restarted.status = 0

    # fetch
    $http.expectGET("/api/builds/#{one.id}").respond(buildsJson.one)
    one = resolve(flush: true, () -> build.one(one.id))
    expect(one).toEqual buildsJson.one

    # restart
    $http.expectPOST("/api/builds/#{restarted.id}/restart").respond(restarted)
    resolve(flush: true, () -> build.restart(one))
    expect(one.status).toEqual 0
