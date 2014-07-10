HabitsApp.module 'Controllers', (Controllers, App, Backbone, Marionette, $, _) ->
  Controllers.HabitsController = Marionette.Controller.extend
    habits: ->
      if !HabitsApp.authToken or !HabitsApp.userEmail
        return HabitsApp.router.navigate("login", trigger: true)

      HabitsApp.appRegion.show new HabitsApp.Views.HabitsView(collection: HabitsApp.habits)
      HabitsApp.Util.fetchHabits((data) -> HabitsApp.habits.reset)

    newHabit: ->
      if !HabitsApp.authToken or !HabitsApp.userEmail
        HabitsApp.router.navigate("login", trigger: true)
      HabitsApp.appRegion.show new HabitsApp.Views.NewHabitView

    habit: (id) ->
      if !HabitsApp.authToken or !HabitsApp.userEmail
        HabitsApp.router.navigate("login", trigger: true)
      HabitsApp.Util.fetchHabits((data) ->
        HabitsApp.appRegion.show new HabitsApp.Views.HabitView(model: HabitsApp.habits.get(id))
      )

    login: ->
      HabitsApp.appRegion.show new HabitsApp.Views.LoginView

    signup: ->
      HabitsApp.appRegion.show new HabitsApp.Views.SignupView

    logout: ->
      HabitsApp.authToken = ""
      HabitsApp.userEmail = ""
      HabitsApp.router.navigate("login", trigger: true)
