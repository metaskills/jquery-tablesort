###
  A simple, lightweight jQuery plugin for creating sortable tables.
  Original: https://github.com/kylefox/jquery-tablesort
  CoffeeScript: https://github.com/metaskills/jquery-tablesort
###

$ = window.jQuery

class $.tablesort
  
  @DEBUG = false
  
  @defaults =
    debug: @DEBUG
    asc:   'sorted ascending'
    desc:  'sorted descending'
    tbodySelector: 'tbody:first'
    trSelector:    'tr'
  
  constructor: (table, settings={}) ->
    @table = $(table)
    @settings = $.extend {}, @constructor.defaults, settings
    @tableBody = @table.find @settings.tbodySelector
    @tableHeaders = @table.find('thead th')
    @tableHeaders.bind 'click.tablesort', @headerClicked
    @sortedHeader = null
    @sortedDirection = null
    @sortedIndex = null
  
  sort: (th, direction) ->
    @setCurrentSorted th, @getDefaultOrReverseDirection(th, direction)
    start = new Date()
    rows = $.makeArray @tableBody.find(@settings.trSelector)
    return if rows.length is 0
    @tableHeaders.removeClass "#{@settings.asc} #{@settings.desc}"
    @table.trigger 'tablesort:start', [@]
    @log "Sorting by #{@sortedHeader.text()} #{@sortedDirection}"
    @tableBody.append row for row in rows.sort(@rowSorter)
    @sortedHeader.addClass @settings[@sortedDirection]
    @log "Sort finished in #{(new Date()).getTime() - start.getTime()} ms"
    @table.trigger 'tablesort:complete', [@]

  destroy: ->
    @tableHeaders.unbind 'click.tablesort'
    @table.data 'tablesort', null
  
  # Private
  
  rowSorter: (a, b) =>
    aRow = $(a)
    bRow = $(b)
    aValue = @sortValueForCell @sortedHeader, @cellToSort(aRow)
    bValue = @sortValueForCell @sortedHeader, @cellToSort(bRow)
    if aValue > bValue
      1 * @dirMultiplier()
    else if aValue < bValue
      -1 * @dirMultiplier()
    else
      0
  
  dirMultiplier: ->
    if @sortedDirection is 'asc' then 1 else -1

  setCurrentSorted: (th, direction) ->
    @sortedHeader = th
    @sortedDirection = direction
    @sortedIndex = @tableHeaders.index(th)
  
  headerClicked: (event) =>
    th = $(event.target)
    dir = @getDefaultOrReverseDirection(th)
    @sort th dir
  
  getDefaultOrReverseDirection: (th, preferedDir) ->
    return preferedDir if preferedDir
    if @sortedHeader?.text() is th.text()
      @reverseDirection()
    else
      'asc'
  
  reverseDirection: (direction) -> 
    dir = direction or @sortedDirection
    if dir is 'asc' then 'desc' else 'asc'
  
  log: (msg) ->
    debugging = @constructor.DEBUG or @settings.debug
    logability = window.console?.log?
    console.log "[tablesort] #{msg}" if debugging and logability
  
  cellToSort: (row) ->
    $(row.find('td').get(@sortedIndex))
  
  sortValueForCell: (th, td) ->
    if sortBy = th.data().sortBy
      return if typeof sortBy is 'function' then sortBy(th, td, @) else sortBy
    td.data().sortValue or td.text()


$.fn.tablesort = (settings) ->
  @each ->
    table = $(this)
    table.data('tablesort')?.destroy()
    tablesort = new $.tablesort table, settings
    table.data 'tablesort', tablesort


