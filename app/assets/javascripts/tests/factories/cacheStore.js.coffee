describe "cacheStore", ->

  $q       = null
  $scope   = null
  cache    = null
  succVal  = null
  failVal  = null
  $apply   = null
  rs       = null

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

  testObj3 = {
    id:   15
    name: "MyName3"
  }

  beforeEach ->
    module("CI")
    inject ["$q", '$rootScope', 'cacheStore',
      (_$q_, _$scope_, cacheStore) ->
        $q      = _$q_
        $scope  = _$scope_.$new()
        $apply  = _.bind $scope.$apply, $scope
        cache   = cacheStore()
    ]

  beforeEach ->
    succVal = failVal = rs = null


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
        cache.collection(1).put defer.promise


    describe "put()", ->

      it "should keep capacity in collections cache", ->
        expect(cache.cache.collections.info().size).toBe 1
        $apply ->
          cache.collection(2).put defer.promise
        expect(cache.cache.collections.info().size).toBe 2
        $apply ->
          cache.collection(3).put defer.promise
        expect(cache.cache.collections.info().size).toBe 2

      describe "new collection to cache", ->

        describe "when collection is pure value", ->
          it "should add collection to cache", ->
            $apply ->
              cache.collection(2).put items
            expect(cache.cache.collections.get(2)).toBe items

          it "should return promise", ->
            $apply ->
              rs = cache.collection(2).put items
              rs.then succ, fail
            expect(succVal).toBe items

        describe "when collection is promise", ->
          it "should add collection to cache", ->
            $apply ->
              cache.collection(2).put defer.promise
            expect(cache.cache.collections.get(2)).toBe items

          it "should return promise", ->
            $apply ->
              rs = cache.collection(2).put defer.promise
              rs.then succ, fail
            expect(succVal).toBe items

          describe "and was rejected", ->
            it "should ignore it", ->
              d = $q.defer()
              $apply ->
                rs = cache.collection(2).put d.promise
              d.reject 'fail'
              expect(cache.cache.collections.get(2)).toBe undefined


    describe "get()", ->

      describe "when collection exists", ->
        it "should return it", ->
          $apply ->
            cache.collection(1).get().then succ, fail
          expect(succVal).toBe items

      describe "when collection does not exists", ->
        it "should return rejected promise", ->
          $apply ->
            cache.collection(2).get().then succ, fail
          expect(failVal).toBe '2'

        describe "and pass callback", ->
          it "should add items from it to cache", ->
            f = () -> items
            $apply ->
              cache.collection(2).get(f).then succ, fail
              rs = cache.cache.collections.get(2)
            expect(succVal).toBe items
            expect(rs).toBe items


    describe "addItem()", ->

      describe "when collection exists", ->
        describe "and item is pure value", ->
          it "should add item to collection", ->
            $apply ->
              cache.collection(1).addItem testObj2
            expect(cache.cache.collections.get(1).length).toBe 2
            expect(cache.cache.collections.get(1)[1]).toBe testObj2

          it "should return promise", ->
            $apply ->
              rs = cache.collection(1).addItem testObj2
              rs.then succ, fail
            expect(succVal).toBe testObj2

        describe "when value is promise", ->
          d = null
          beforeEach ->
            d = $q.defer()
            d.resolve testObj2

          it "should add item to collection", ->
            $apply ->
              cache.collection(1).addItem d.promise
            expect(cache.cache.collections.get(1).length).toBe 2
            expect(cache.cache.collections.get(1)[1]).toBe testObj2

          it "should return promise", ->
            $apply ->
              rs = cache.collection(1).addItem d.promise
              rs.then succ, fail
            expect(succVal).toBe testObj2

          describe "and was rejected", ->
            r = null
            beforeEach ->
              r = $q.defer()
              r.reject 'fail'

            it "should ignore it", ->
              $apply ->
                cache.collection(1).addItem r.promise
              expect(cache.cache.collections.get(1)[1]).toBe undefined


  describe '(item)', ->
    item  = null
    defer = null

    beforeEach ->
      $scope.$apply ->
        item  = testObj
        defer = $q.defer()
        defer.resolve item

    beforeEach ->
      $apply ->
        cache.item(1).put defer.promise


