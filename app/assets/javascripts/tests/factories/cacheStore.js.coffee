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

  sharedBehaviorForGet = (f) ->

    describe "get()", ->

      cacheName = cacheItem = item = defer = null

      beforeEach ->
        context = f()
        cacheName = context.cacheName
        cacheItem = context.cacheItem
        item      = context.item
        defer     = $q.defer()

      beforeEach ->
        $apply ->
          defer.resolve item
          cacheItem(1).put defer.promise

      describe "when item exists", ->
        it "should return it", ->
          $apply ->
            cacheItem(1).get().then succ, fail
          expect(succVal).toBe item

      describe "when item does not exists", ->
        it "should return rejected promise", ->
          $apply ->
            cacheItem(2).get().then succ, fail
          expect(failVal).toBe '2'

        describe "and pass callback", ->
          it "should add item from it to cache", ->
            f = () -> item
            $apply ->
              cacheItem(2).get(f).then succ, fail
              rs = cache.cache[cacheName].get(2)
            expect(succVal).toBe item
            expect(rs).toBe item


  sharedBehaviorForPut = (f) ->

    describe "put()", ->

      cacheName = cacheItem = item = defer = null

      beforeEach ->
        context = f()
        cacheName = context.cacheName
        cacheItem = context.cacheItem
        item      = context.item
        defer     = $q.defer()

      beforeEach ->
        $apply ->
          defer.resolve item
          cacheItem(1).put defer.promise

      it "should keep capacity in cache", ->
        $apply ->
          expect(cache.cache[cacheName].info().size).toBe 1
        $apply ->
          cacheItem(2).put defer.promise
        expect(cache.cache[cacheName].info().size).toBe 2
        $apply ->
          cacheItem(3).put defer.promise
        expect(cache.cache[cacheName].info().size).toBe 2

      describe "new item to cache", ->

        describe "when item is pure value", ->
          it "should add it to cache", ->
            $apply ->
              cacheItem(2).put item
            expect(cache.cache[cacheName].get(2)).toBe item

          it "should return promise", ->
            $apply ->
              rs = cacheItem(2).put item
              rs.then succ, fail
            expect(succVal).toBe item

        describe "when item is promise", ->
          it "should add it to cache", ->
            $apply ->
              cacheItem(2).put defer.promise
            expect(cache.cache[cacheName].get(2)).toBe item

          it "should return promise", ->
            $apply ->
              rs = cacheItem(2).put defer.promise
              rs.then succ, fail
            expect(succVal).toBe item

          describe "and was rejected", ->
            it "should ignore it", ->
              d = $q.defer()
              $apply ->
                rs = cacheItem(2).put d.promise
              d.reject 'fail'
              expect(cache.cache[cacheName].get(2)).toBe undefined


  describe '(collection)', ->
    items = null
    defer = null

    beforeEach ->
      $scope.$apply ->
        items = [testObj]
        defer = $q.defer()


    sharedBehaviorForPut () ->
      cacheName: 'collections',
      cacheItem: cache.collection,
      item:      items


    sharedBehaviorForGet () ->
      cacheName: 'collections',
      cacheItem: cache.collection,
      item:      items


    describe "addItem()", ->

      beforeEach ->
        $scope.$apply ->
          defer.resolve items
          cache.collection(1).put defer.promise

      describe "when collection exists", ->
        describe "and item is pure value", ->
          it "should add it to collection", ->
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


    sharedBehaviorForPut () ->
      cacheName: 'items',
      cacheItem: cache.item
      item:      item


    sharedBehaviorForGet () ->
      cacheName: 'items',
      cacheItem: cache.item,
      item:      item
