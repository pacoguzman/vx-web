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
        item      = angular.copy context.item
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
        item      = angular.copy context.item
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


  it "should be create twice", ->
    inject ['cacheStore',
      (cacheStore) ->
        cacheStore()
    ]

  describe '(collection)', ->
    items = null
    defer = null

    beforeEach ->
      $scope.$apply ->
        items = angular.copy [testObj]
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

          describe "and item already in collection", ->
            it "cannot add", ->
              $apply ->
                cache.collection(1).addItem testObj2
              expect(cache.cache.collections.get(1).length).toBe 2
              $apply ->
                rs = cache.collection(1).addItem testObj2
                rs.then succ, fail
              expect(cache.cache.collections.get(1).length).toBe 2
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

          describe "and item already in collection", ->
            it "cannot add", ->
              $apply ->
                cache.collection(1).addItem d.promise
              expect(cache.cache.collections.get(1).length).toBe 2
              $apply ->
                rs = cache.collection(1).addItem d.promise
                rs.then succ, fail
              expect(cache.cache.collections.get(1).length).toBe 2
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
        item  = angular.copy testObj
        defer = $q.defer()


    sharedBehaviorForPut () ->
      cacheName: 'items',
      cacheItem: cache.item
      item:      item


    sharedBehaviorForGet () ->
      cacheName: 'items',
      cacheItem: cache.item,
      item:      item


    describe "update()", ->

      beforeEach ->
        $apply ->
          defer.resolve item
          cache.item(1).put defer.promise

      describe "when item found in items cache", ->
        it "should update it", ->
          cache.item(1).update name: 'updated'
          expect(cache.cache.items.get(1).name).toBe 'updated'

        it "should return resolved promise with", ->
          $apply ->
            cache.item(1).update(name: "updated").then succ, fail
          expect(succVal).toBe item

      describe "when item found in collection", ->
        items = null

        beforeEach ->
          items = angular.copy [testObj, testObj2]
          cache.cache.items.remove('1')
          cache.collection(1).put items

        it "should update it", ->
          cache.item(testObj.id).update name: "updated", 1
          expect(cache.cache.collections.get('1')[0].name).toBe 'updated'
          expect(cache.cache.collections.get('1')[0]).toBe items[0]
          expect(cache.cache.collections.get('1')[1].name).toBe 'MyName2'

        it "should return resolved pormise with it", ->
          $apply ->
            cache.item(testObj.id).update(name: "updated", 1).then succ, fail
          expect(succVal).toBe items[0]

      describe "when item not found in caches", ->
        it "cannot touch any items", ->
          cache.item(2).update name: "updated"
          expect(cache.cache.items.get(2)).toBe undefined
          expect(cache.cache.items.get(1).name).toBe 'MyName'

        it "should return rejected promise", ->
          $apply ->
            cache.item(2).update(name: "updated").then succ, fail
          expect(failVal).toBe '2'


    describe "remove()", ->

      beforeEach ->
        $apply ->
          defer.resolve item
          cache.item(1).put defer.promise

      describe "when item found in items cache", ->
        it "should remove it", ->
          cache.item(1).remove()
          expect(cache.cache.items.get(1)).toBe undefined

        it "should return resolved promise with it", ->
          $apply ->
            cache.item(1).remove().then succ, fail
          expect(succVal).toBe item

      describe "when item found in collection", ->
        items = null

        beforeEach ->
          items = angular.copy [testObj, testObj2]
          cache.cache.items.remove('1')
          cache.collection(1).put items

        it "should update it", ->
          cache.item(testObj.id).remove(1)
          expect(cache.cache.collections.get('1').length).toBe 1
          expect(cache.cache.collections.get('1')[0]).toEqual testObj2
          expect(cache.cache.collections.get('1')).toBe items

        it "should return resolved pormise with it", ->
          $apply ->
            cache.item(testObj.id).remove(1).then succ, fail
          expect(succVal).toEqual testObj

      describe "when item not found in caches", ->
        beforeEach ->
          items = angular.copy [testObj, testObj2]
          cache.collection(1).put items

        it "cannot touch any items", ->
          cache.item(3).remove(1)
          expect(cache.cache.items.get(1)).toEqual testObj
          expect(cache.cache.collections.get(1).length).toBe 2

        it "should return rejected promise", ->
          $apply ->
            cache.item(3).remove(1).then succ, fail
          expect(failVal).toBe '3'

