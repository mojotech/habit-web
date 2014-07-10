HabitsApp.module 'Collections', (Collections, App, Backbone, Marionette, $, _) ->
  Collections.Habits = Backbone.Collection.extend
    url: 'http://localhost:3000/habits'
    parse: (response) ->
      for habit in response.habits
        values = _(response.checkins).filter((checkin) =>
          _.contains habit.checkin_ids, checkin.id
        ).map((checkin) ->
          checkin.value
        )
        if values.length == 0
          habit.value = 0
        else
          habit.value = _.reduce(values, (prev, curr) ->
            prev + curr
          )
      response.habits
