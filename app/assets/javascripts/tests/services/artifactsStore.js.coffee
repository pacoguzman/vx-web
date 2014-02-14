describe "artifactsStore", ->

  $scope     = null
  artifacts  = null
  $http      = null
  succVal    = null
  failVal    = null

  succ = (it) ->
    succVal = it

  fail = (it) ->
    failVal = it

  testObj = {
    id:   12
    build_id: 1
    name: "MyName"
  }

  testObj2 = {
    id:   14
    build_id: 1
    name: "MyName"
  }

  evSource = eventSourceMock()

  beforeEach module("Vx")

  beforeEach ->
    module ($provide) ->
      () ->
        $provide.value 'eventSource', evSource
    evSource.reset()

  beforeEach ->
    inject ['$rootScope',
      (_$scope_) ->
        $scope   = _$scope_.$new()
    ]

  beforeEach ->
    inject ['$injector',
      ($injector) ->
        $http  = $injector.get("$httpBackend")
        artifacts = $injector.get("artifactsStore")
    ]
    succVal = failVal = null


  describe "all()", ->

    beforeEach ->
      $http.expectGET('/api/builds/1/artifacts').respond(angular.copy [testObj, testObj2])

    it "should return all artifacts for build", ->
      $scope.$apply ->
        artifacts.all(1).then succ, fail
      $http.flush()
      expect(succVal).toEqual [testObj, testObj2]


  describe "with eventSource", ->

    f      = null
    before = null

    beforeEach ->
      [[_, f]] = evSource.subscriptions()

    it "should subscribe to 'artifacts'", ->
      [[name, _]] = evSource.subscriptions()
      expect(name).toEqual 'artifacts'
      expect(f).toBeDefined()


    describe "new artifact from event", ->

      beforeEach ->
        $http.expectGET('/api/builds/1/artifacts').respond(angular.copy [testObj, testObj2])
        $scope.$apply ->
          artifacts.all(1).then succ, fail
        $http.flush()
        expect(succVal.length).toBe 2

      it "should add to collection if in same build", ->
        e =
          event: 'created',
          data:
            id: 1
            build_id: 1
            name: "Created"
        f(e)
        $scope.$apply ->
          artifacts.all(1).then succ, fail
        expect(succVal.length).toBe 3
        expect(succVal[2]).toEqual e.data

    describe "updated artifact from event", ->

      describe "(model)", ->
        beforeEach ->
          $http.expectGET('/api/builds/1/artifacts').respond(angular.copy [testObj])
          $scope.$apply ->
            artifacts.all(1).then succ, fail
          $http.flush()
          expect(succVal).toEqual [testObj]

        it "should update if found", ->
          e =
            event: 'updated',
            id: 12
            data:
              build_id: 1
              name: "xUpdated"
          f(e)
          $scope.$apply ->
            artifacts.all(1).then succ, fail
          expect(succVal[0].name).toEqual 'xUpdated'


