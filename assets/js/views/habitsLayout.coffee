HabitsApp.module 'Views', (Views, App, Backbone, Marionette, $, _) ->
  Views.HabitsView = Marionette.CompositeView.extend
    template: "#habits"
    childView: Views.HabitItemView
    childViewContainer: "#habits-list"
