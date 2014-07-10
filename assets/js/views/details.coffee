HabitsApp.module 'Views', (Views, App, Backbone, Marionette, $, _) ->
  Views.HabitView = Marionette.ItemView.extend
    template: "#habit"
    ui:
      deleteButton: "#delete-btn"
    events:
      "click @ui.deleteButton": "deleteHabit"
    deleteHabit: ->
      $.ajax
        url: "http://localhost:3000/habits/#{@model.id}"
        method: "DELETE"
        headers: Authorization: HabitsApp.Util.authHeader()
        success: (data) ->
          HabitsApp.Util.fetchHabits((data) ->
            App.router.navigate("habits", trigger: true)
          )
