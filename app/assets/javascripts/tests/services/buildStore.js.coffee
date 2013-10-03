describe "buildStore", ->

  $scope   = null
  builds   = null
  $http    = null
  succVal  = null
  failVal  = null

  succ = (it) ->
    succVal = it

  fail = (it) ->
    failVal = it

  testObj = {
    id:   12
    name: "MyName"
  }

  testObj2 = {
    id:   14
    name: "MyName"
  }

  evSource = eventSourceMock()

  beforeEach module("CI")

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
        builds = $injector.get("buildStore")
    ]
    succVal = failVal = null


  describe "create()", ->

    beforeEach ->
      $http.expectPOST('/api/projects/1/builds').respond('success')

    it "should send POST request", ->
      $scope.$apply ->
        builds.create(1).then succ, fail
      $http.flush()
      expect(succVal).toEqual 'success'


  describe "all()", ->

    beforeEach ->
      $http.expectGET('/api/projects/1/builds').respond(angular.copy [testObj, testObj2])

    it "should return all builds for project", ->
      $scope.$apply ->
        builds.all(1).then succ, fail
      $http.flush()
      expect(succVal).toEqual [testObj, testObj2]


  describe "one()", ->

    beforeEach ->
      $http.expectGET('/api/builds/1').respond(testObj)

    it "should return one build", ->
      $scope.$apply ->
        builds.one(1).then succ, fail
      $http.flush()
      expect(succVal).toEqual testObj


  describe "with eventSource", ->

    f      = null
    before = null

    beforeEach ->
      [[_, f]] = evSource.subscriptions()

    it "should subscribe to 'builds'", ->
      [[name, _]] = evSource.subscriptions()
      expect(name).toEqual 'builds'
      expect(f).toBeDefined()


    describe "new build from event", ->

      beforeEach ->
        $http.expectGET('/api/projects/1/builds').respond(angular.copy [testObj, testObj2])
        $scope.$apply ->
          builds.all(1).then succ, fail
        $http.flush()
        expect(succVal.length).toBe 2

      it "should add to collection if in same project", ->
        e =
          event: 'created',
          data:
            id: 1
            project_id: 1
            name: "Created"
        f(e)
        $scope.$apply ->
          builds.all(1).then succ, fail
        expect(succVal.length).toBe 3
        expect(succVal[2]).toEqual e.data


    describe "destroy build from event", ->

      beforeEach ->
        $http.expectGET('/api/projects/1/builds').respond(angular.copy [testObj, testObj2])
        $scope.$apply ->
          builds.all(1).then succ, fail
        $http.flush()
        expect(succVal.length).toBe 2

      it "should delete from collection if in same project", ->
        e =
          event: 'destroyed',
          id: 12
          data:
            project_id: 1
        f(e)
        $scope.$apply ->
          builds.all(1).then succ, fail
        expect(succVal.length).toBe 1
        expect(succVal[0].id).toEqual 14

    describe "updated build from event", ->

      describe "(model)", ->
        beforeEach ->
          $http.expectGET('/api/builds/12').respond(angular.copy testObj)
          $scope.$apply ->
            builds.one(12).then succ, fail
          $http.flush()
          expect(succVal).toEqual testObj

        it "should update if found", ->
          e =
            event: 'updated',
            id: 12
            data:
              project_id: 1
              name: "xUpdated"
          f(e)
          $scope.$apply ->
            builds.one(12).then succ, fail
          expect(succVal.name).toEqual 'xUpdated'

      describe "(collection)", ->
        beforeEach ->
          $http.expectGET('/api/projects/1/builds').respond(angular.copy [testObj, testObj2])
          $scope.$apply ->
            builds.all(1).then succ, fail
          $http.flush()
          expect(succVal.length).toBe 2

        it "should update if build found in collection", ->
          e =
            event: 'updated',
            id: 12
            data:
              project_id: 1
              name: "sUpdated"
          f(e)
          $scope.$apply ->
            builds.all(1).then succ, fail
          expect(succVal.length).toBe 2
          expect(succVal[0].name).toEqual 'sUpdated'
          expect(succVal[1].name).toEqual 'MyName'

