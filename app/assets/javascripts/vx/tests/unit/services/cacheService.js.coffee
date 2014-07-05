describe "cacheService", ->

  cache  = null
  $scope = null
  $q     = null

  resolve = (key, data) ->
    rs = cache.fetch key, () ->
      q = $q.defer()
      q.resolve data
      q.promise
    $scope.$digest()
    ret = null
    rs.then (data) ->
      ret = data
    $scope.$digest()
    ret

  fetched = (key) ->
    rs =  null
    cache.fetch("key").then (it) ->
      rs = it
    $scope.$digest()
    rs

  beforeEach ->
    module("Vx")
    inject ['$q', '$rootScope', 'cacheService',
      (_$q, _$scope, cacheService) ->
        $q     = _$q
        $scope = _$scope.$new()
        cache  = cacheService('tests')
    ]

  it "should fetch key", ->
    item = {id: "1"}

    expect(resolve "key", item).toBe item
    expect(fetched "key").toBe item

  it "sould push one value", ->
    col  = []
    item = { id: "1" }

    resolve 'key', col
    expect(fetched "key").toBe col

    cache.push('key', item)
    expect(fetched "key").toBe col
    expect(col.length).toEqual 1
    expect(col[0]).toBe item

  it "should push values", ->
    col  = []
    item1 = { id: "1" }
    item2 = { id: "2" }

    resolve 'key', col
    expect(fetched "key").toBe col

    cache.push('key', [item1, item2])
    expect(fetched "key").toBe col
    expect(col.length).toEqual 2
    expect(col[0]).toBe item1
    expect(col[1]).toBe item2

  it "should remove key from cache", ->
    item = { id: "1" }

    resolve 'key', item
    expect(fetched "key").toBe item

    cache.removeKey 'not key'
    cache.removeKey 'key'

    rs = null
    cache.fetch('key').catch (err) ->
      rs = err

    $scope.$digest()
    expect(rs).toEqual 'key key missing'

  it "should remove object from collection", ->
    col = []
    item1 = { id: "1" }
    item2 = { id: "2" }

    resolve 'key', col
    expect(fetched "key").toBe col

    cache.push 'key', [item1, item2]
    expect(col).toEqual [item1, item2]

    cache.removeAll 'key', '1'
    expect(col).toEqual [item2]

    cache.removeAll 'key', '2'
    expect(col).toEqual []

  it "should update object in key", ->
    item = {  id: '1', name: "name" }

    resolve 'key', item
    expect(fetched 'key').toBe item

    cache.updateOne 'key', { name: "newName" }
    expect(item).toEqual { id: '1', name: 'newName' }

  it "should update objects in collection", ->
    col = []
    item1 = { id: "1", name: "name 1" }
    item2 = { id: "2", name: "name 2" }

    resolve 'key', col
    expect(fetched "key").toBe col

    cache.push 'key', [item1, item2]
    expect(col.length).toEqual 2

    cache.updateAll 'key', angular.extend(item1, name: "new name 1")
    expect(item1).toEqual id: "1", name: "new name 1"

    cache.updateAll 'key', angular.extend(item2, name: "new name 2")
    expect(item2).toEqual id: "2", name: "new name 2"

