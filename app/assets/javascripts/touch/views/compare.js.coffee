class window.CompareView extends Backbone.View

  tag: ->
    app.models.tag
    
  initialize: ->
    app.models.tag.bind "change", @changeTag, @
    
  events:
    "click a.nav": "themesClick"
    "click a.share": "share"
    
  themesClick: ->
    app.router.navigate "#{app.models.election.namespace()}/#{app.collections.selectedCandidacies.toParam()}", true
    
  share: ->
    app.router.share()
    
  changeTag: ->
    $(".title", @el).html @tag().name()
    
  render: ->
    $(@el).html Mustache.to_html($('#compare-template').html(), tag: @tag())