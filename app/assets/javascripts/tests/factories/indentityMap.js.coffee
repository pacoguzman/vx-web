describe "identityMap", ->

  $q       = null
  $scope   = null
  imap     = null
  succVal  = null
  failVal  = null

  succ = (args) ->
    succVal = args

  fail = (args) ->
    failVal = args


  testObj = {
    id:   12
    name: "MyName"
  }

  testObj2 = {
    id:   14
    name: "MyName2"
  }

  beforeEach ->
    module("CI")
    inject ["$q", '$rootScope', 'identityMap',
      (_$q_, _$scope_, identityMap) ->
        $q      = _$q_
        $scope  = _$scope_
        imap    = identityMap()
    ]

  beforeEach ->
    succVal = failVal = null


  describe '(collection)', ->
    items = null
    defer = null

    beforeEach ->
      $scope.$apply ->
        items = [testObj]
        defer = $q.defer()
        defer.resolve items

    beforeEach ->
      $scope.$apply ->
        imap.collection(1).put defer.promise


    describe "put()", ->

      it "should keep capacity in collections cache", ->
        expect(imap.cache.collections.info().size).toBe 1
        $scope.$apply ->
          imap.collection(2).put defer.promise
        expect(imap.cache.collections.info().size).toBe 2
        $scope.$apply ->
          imap.collection(3).put defer.promise
        expect(imap.cache.collections.info().size).toBe 2

      it "should put new collection to cache", ->
        $scope.$apply ->
          imap.collection(1).put defer.promise
          imap.cache.collections.get(1).then succ, fail
        expect(succVal).toBe items

      it "should return promise with new collection", ->
        rs = null
        $scope.$apply ->
          rs = imap.collection(1).put defer.promise
        expect(rs).toBe defer.promise

      describe "when put rejected promise", ->
        it "also store it in cache", ->
          rs = null
          d = $q.defer()
          $scope.$apply ->
            rs = imap.collection(1).put d.promise
          d.reject 'fail'
          $scope.$apply ->
            imap.cache.collections.get(1).then succ, fail
          expect(failVal).toEqual 'fail'
          expect(rs).toBe d.promise


    describe "get()", ->

      describe "when collection exists", ->
        it "should return its", ->
          $scope.$apply ->
            imap.collection(1).get().then succ, fail
          expect(succVal).toBe items

      describe "when collection does not exists", ->
        it "should return rejected promise", ->
          $scope.$apply ->
            imap.collection(2).get().then succ, fail
          expect(failVal).toEqual '2'

        describe "and pass callback", ->
          it "should add new collection using callback", ->
            newItems = [testObj2]
            d        = $q.defer()
            $scope.$apply ->
              imap.collection(2).get () ->
                d.promise
            d.resolve newItems
            $scope.$apply ->
              imap.collection(2).get().then succ, fail
            expect(succVal).toBe newItems

          it "should return promise with new collection", ->
            newItems = [testObj2]
            rs       = null
            d        = $q.defer()
            $scope.$apply ->
              rs = imap.collection(2).get () ->
                d.promise
            d.resolve newItems
            $scope.$apply ->
              rs.then succ, fail
            expect(succVal).toBe newItems


    describe "add()", ->

      describe "when collection exists", ->
        it "should add new item to collection", ->
          $scope.$apply ->
            imap.collection(1).add testObj2
          $scope.$apply ->
            imap.collection(1).get().then succ, fail
          expect(succVal).toBe items
          expect(succVal.length).toBe 2
          expect(succVal[1]).toBe testObj2

        it "should return promise with new item", ->
          rs = null
          $scope.$apply ->
            rs = imap.collection(1).add testObj2
          $scope.$apply ->
            rs.then succ, fail
          expect(succVal).toBe testObj2

      describe "when collection does not exists", ->
        it "should return rejected promise", ->
          rs = null
          $scope.$apply ->
            rs = imap.collection(2).add testObj2
            rs.then succ, fail
          expect(failVal).toBe '2'
