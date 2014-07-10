HabitsApp.module 'Views', (Views, App, Backbone, Marionette, $, _) ->
  Views.HabitsCollectionView = Marionette.ItemView.extend
    tagName: "ul"
    childView: HabitsApp.Views.HabitItemView
    collection: HabitsApp.habits
