App = Ember.Application.create()

# Controllers
App.Row = Ember.ArrayController.extend
  cells: []

App.lifes = Ember.ArrayController.create
  content: [],
  getCell: ((x, y) ->
    @get('content')[y * 10 + x]
  ),
  rows: (->
    result = []
    cur = App.Row.create(cells: [])
    for cell in @get('content')
      cur.get('cells').push(cell)
      if cur.get('cells').length == 10
        result.push(cur)
        cur = App.Row.create(cells: [])
    result
  ).property('content'),
  getNearbyCells: ((x, y)->
    [
      @getCell(x - 1, y - 1),
      @getCell(x - 0, y - 1),
      @getCell(x + 1, y - 1),
      @getCell(x - 1, y - 0),
      @getCell(x + 1, y - 0),
      @getCell(x - 1, y + 1),
      @getCell(x - 0, y + 1),
      @getCell(x + 1, y + 1),
    ]
  )

App.Life = Ember.Controller.extend
  lifesBinding: 'App.lifes',
  state: (->
    if @get('isLive')
      '■'
    else
      '□'
  ).property('isLive'),
  cur: 0,
  next: (->
    nearbyCells = @get('lifes').getNearbyCells(@get('x'), @get('y'))
    sum = nearbyCells.without(undefined).getEach('cur').reduce((m,v) -> m + v)
    if @get('isLive')
      if sum == 2 || sum == 3
        1
      else
        0
    else
      if sum == 3
        1
      else
        0
  ).property('lifes.@each.cur'),
  tmp: null,
  prepare: (->
    @set('tmp', @get('next'))
  ),
  goNext: (->
    @set('cur', @get('tmp'))
  ),
  flip: (->
    if @get('isLive')
      @set('cur', 0)
    else
      @set('cur', 1)
  ),
  isLive: (->
    @get('cur') == 1
  ).property('cur')


# Views
App.ApplicationView = Ember.View.extend()

App.LifeCanvasView = Ember.View.extend
  templateName: 'life_canvas',
  lifesBinding: 'App.lifes.content',
  rowsBinding: 'App.lifes.rows',

# Setup
for i in [0..99]
  App.lifes.content.pushObject(App.Life.create(x: i % 10, y: Math.floor(i / 10)))

App.lifes.getCell(3, 4).flip()
App.lifes.getCell(4, 4).flip()
App.lifes.getCell(5, 4).flip()
App.lifes.getCell(3, 5).flip()
App.lifes.getCell(4, 6).flip()

nextGeneration = (->
  App.lifes.content.invoke('prepare')
  App.lifes.content.invoke('goNext')
)

setInterval((->
  nextGeneration()
), 1000)


