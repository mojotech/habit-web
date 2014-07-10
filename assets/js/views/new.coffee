HabitsApp.module 'Views', (Views, App, Backbone, Marionette, $, _) ->
  Views.NewHabitView = Marionette.ItemView.extend
    template: "#habits-new"
    ui:
      habit: "#new-habit"
      saveButton: "#save-btn"
    events:
      "click @ui.saveButton": "saveHabit"
    saveHabit: ->
      $.ajax
        url: 'http://localhost:3000/habits'
        method: 'POST'
        data:
          habit:
            title: @ui.habit.val()
        headers: Authorization: HabitsApp.Util.authHeader()
        success: (data) ->
          HabitsApp.Util.fetchHabits((data) ->
            App.router.navigate("habits", trigger: true)
          )
