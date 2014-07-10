window.HabitsApp = new Marionette.Application()

HabitsApp.addRegions
  appRegion: "#app"

HabitsApp.on "start", ->
  HabitsApp.router = new HabitsApp.Routers.Router(controller: new HabitsApp.Controllers.HabitsController())
  Backbone.history.start()

$ ->
  HabitsApp.habits = new HabitsApp.Collections.Habits()
  HabitsApp.start()
