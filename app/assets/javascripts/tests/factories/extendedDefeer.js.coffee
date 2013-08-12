describe "extendedDefer", ->

  $q       = null
  $scope   = null
  factory  = null

  defer    = null
  ext      = null
  expected = null

  testObj = {
    id:   12
    name: "MyName"
  }

  testObj2 = {
    id:   14
    name: "MyName"
  }

  beforeEach ->
    module("CI")
    inject ["$q", '$rootScope', "extendedDefer",
      (_$q_, _$scope_, _factory_) ->
        $q      = _$q_
        $scope  = _$scope_
        factory = _factory_
    ]

  beforeEach ->
    defer    = $q.defer()
    ext      = factory(defer)
    expected = []

  beforeEach ->
    $scope.$apply ->
      defer.resolve [testObj, testObj2]


  describe "all()", ->

    it "should be defined", ->
      expect(ext.all).toBeDefined()

    it "should return promise", ->
      expect(ext.all().then).toBeDefined()

    it "should gets values", ->
      $scope.$apply ->
        ext.all().then (v) ->
          expected = v
      expect(expected).toEqual [testObj, testObj2]


  describe "add()", ->

    it "should be defined", ->
      expect(ext.delete).toBeDefined()

    it "should add object to collection", ->
      $scope.$apply ->
        ext.add id: 99, name: "foo"
        defer.promise.then (its) ->
          expected = its
      expect(expected.length).toBe 3
      expect(expected[2].id).toEqual 99
      expect(expected[2].name).toEqual 'foo'


  describe "delete()", ->

    it "should be defined", ->
      expect(ext.delete).toBeDefined()

    it "should delete object by id", ->
      $scope.$apply ->
        ext.delete(12)
        defer.promise.then (its) ->
          expected = its
      expect(expected.length).toBe 1
      expect(expected[0].id).toEqual 14


  describe "update()", ->

    it "should be defined", ->
      expect(ext.update).toBeDefined()

    it "should update object by id", ->
      $scope.$apply ->
        ext.update(12, name: "changed")
        defer.promise.then (its) ->
          expected = its
      expect(expected[0].id).toEqual 12
      expect(expected[0].name).toEqual "changed"
      expect(expected[1].name).toEqual "MyName"


  describe "find()", ->

    it "should be defined", ->
      expect(ext.find).toBeDefined()

    it "should find objects by id", ->
      $scope.$apply ->
        ext.find(12).then (v) ->
          expected.push v
      expect(expected).toEqual [testObj]


  describe "index()", ->

    it "should be defined", ->
      expect(ext.index).toBeDefined()

    it "should find object indexes", ->
      $scope.$apply ->
        ext.index(12).then (v) ->
          expected.push v
        ext.index(14).then (v) ->
          expected.push v
        ext.index(99).then (v) ->
          expected.push v
      expect(expected).toEqual [0,1,-1]

    describe "when defer rejected", ->

      beforeEach ->
        $scope.$apply ->
          defer = $q.defer()
          defer.reject()

      it "should reject", ->
        ext.index(12).then (v) ->
          expected.push v
        expect(expected).toEqual []


