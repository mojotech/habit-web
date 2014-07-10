HabitsApp.module 'Routers', (Routers, App, Backbone, Marionette, $, _) ->
  Routers.Router = Marionette.AppRouter.extend
    appRoutes:
      "habits": "habits"
      "habits/new": "newHabit"
      "habits/:id": "habit"
      "login": "login"
      "signup": "signup"
      "logout": "logout"
