HabitsApp.module 'Views', (Views, App, Backbone, Marionette, $, _) ->
  Views.HabitItemView = Marionette.ItemView.extend
    tagName: "li"
    template: "#habit-item"
    ui:
      plusBtn: ".plus"
      minusBtn: ".minus"
    modelEvents:
      change: "render"
    events: ->
      "click @ui.plusBtn": _.partial(@checkin, 1)
      "click @ui.minusBtn": _.partial(@checkin, -1)
    checkin: (value) ->
      $.ajax
        url: 'http://localhost:3000/checkins'
        method: 'POST'
        data:
          checkin:
            habit_id: @model.id
            value: value
        headers: Authorization: HabitsApp.Util.authHeader()
        success: (data) ->
          HabitsApp.Util.fetchHabits(->)
