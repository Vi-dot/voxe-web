# ROUTER

class window.AppRouter extends Backbone.Router
  
  routes:
    "": "electionsList"
    ":namespace/:candidacies/:tag": "compare"
    ":namespace/:candidacies": "tagsList"
    ":namespace": "candidatesList"
  
  electionsList: ->
    unless @electionsListView
      @electionsListView = new ElectionsListView(el: "#elections-list", collection: app.collections.elections, model: app.models.election)
      @electionsListView.render()
    
    # get elections
    if _.isEmpty app.collections.elections.models
      app.collections.elections.fetch()
      
    $('body').animate scrollTop: ($('#elections').offset().top - 80), 1000  
      
  candidatesList: (namespace)->
    app.models.election.candidacies.unselect()
    
    unless @candidaciesListView
      @candidaciesListView = new CandidaciesListView(el: "#candidacies-list", model: app.models.election)
      @candidaciesListView.render()
    
    unless _.isEmpty app.collections.elections.models
      election = _.find app.collections.elections.models, (election) ->
        election.namespace() == namespace
      app.models.election.set election.toJSON()
      
    $('body').animate scrollTop: ($('#candidacies').offset().top - 80), 1000  
    
  tagsList: (namespace, names)->
    # redirect if /
    unless names
      return @navigate namespace, true
          
    unless @tagsListView
      @tagsListView = new TagsListView(el: "#tags-list", model: app.models.election)
      @tagsListView.render()
      
    # set candidacies using url
    app.models.election.bind 'change', (election)=>
      namespaces = names.split ','
      _.each election.candidacies.models, (candidacy)->
        candidacy.set selected: true if _.include namespaces, candidacy.namespace()
        
    $('body').animate scrollTop: ($('#tags').offset().top - 80), 1000
    
  compare: (namespace, candidacies, tagNamespace)->
    # redirect if /
    unless tagNamespace
      return @navigate "#{namespace}/#{candidacies}", true
      
    unless @compareView
      @compareView = new CompareView(el: "#propositions-header", collection: app.models.election.tags, model: app.models.election)
      @compareView.render()
      # propositions
      @propositionsView = new PropositionsView(el: "#propositions-list", model: app.models.election, collection: app.collections.propositions)
      @propositionsView.render()
            
    # set candidacies, tag using url
    app.models.election.bind 'change', (election)=>
      # candidacies
      namespaces = candidacies.split ','
      _.each election.candidacies.models, (candidacy)->
        candidacy.set selected: true if _.include namespaces, candidacy.namespace()
      # tag
      _.each election.tags.models, (tag)->
        tag.set selected: true if tag.namespace() == tagNamespace
    
      @propositionsView.loadPropositions()
      
    @propositionsView.loadPropositions()
    $('body').animate scrollTop: ($('#propositions').offset().top - 80), 1000
    
  share: ->
    unless @shareView
      @shareView = new ShareView(el: "#share")
      @shareView.render()
    app.views.application.presentModalView 'share'