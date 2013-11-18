CI.config ["$parseProvider",
  ($parseProvider) ->
    $parseProvider.unwrapPromises(true)
    $parseProvider.logPromiseWarnings(false)
]
