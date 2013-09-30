$             = jQuery
Controller    = require('controller')
helpers       = require('app/helpers')
Post          = require('app/models/post')
User          = require('app/models/user')
State         = require('app/state')
AuthorizeUser = require('app/controllers/users/authorize')
PostList      = require('app/controllers/sidebar/post_list')
NewPost       = require('app/controllers/posts/new')
UserMenu      = require('app/controllers/sidebar/user_menu')
UserProfile   = require('app/controllers/users/profile')

class Sidebar extends Controller
  helpers: helpers
  className: 'sidebar'

  constructor: ->
    super

    @$el.activeArea()

    @on('click', 'nav a[data-state]', @clickState)
    @on('click', 'nav .search', @toggleSearch)
    @on('click', '.profile', @profile)
    @on('click', '.newPost', @newPost)
    @on('click', '.landing', @landing)
    @on('search focus', 'input[type=search]', @search)
    $(window).on('keydown', @keydown)

    State.change 'sidebar', @setState
    State.observeKey 'user', @render

    @render()

  render: =>
    @user = State.get('user')
    @html(@view('sidebar')(this))

    @$postsPopular = @$('.posts-popular')
    @$postsNewest  = @$('.posts-newest')
    @$postsSearch  = @$('.posts-search')
    @$searchInput  = @$('input[type=search]')
    @$nav          = @$('nav')

    @postsPopular = new PostList(
      el: @$postsPopular,
      collection: Post.popular,
      hasIndex: true
    )

    @postsNewest = new PostList(
      el: @$postsNewest,
      collection: Post.newest
    )

    @postsSearch = new PostList(
      el: @$postsSearch,
      collection: Post.search
    )

    @setState()

  # Private

  clickState: (e) =>
    State.set(sidebar: $(e.currentTarget).data('state'))

  nextPost: =>
    $active = @$('.item.active:visible').next()
    $active = @$('.item:visible:first') unless $active[0]
    $active.click()

  previousPost: =>
    $active = @$('.item.active:visible:first')
    $active.prev().click()

  # Toggle between newest/popular states

  setState: (state = 'popular') =>
    @$('[data-state]').removeClass('active')
    @$("[data-state=#{state}]").addClass('active')

  # Modals

  profile: (e) =>
    e.preventDefault()

    State.withUser (user) =>
      unless @userMenu
        @userMenu = new UserMenu(user)
        @append @userMenu

      @userMenu.toggle()

  newPost: (e) =>
    e.preventDefault()
    NewPost.open()

  landing: (e) =>
    e.preventDefault()
    State.set(post: null)

  # Search

  toggleSearch: =>
    @$nav.toggleClass('search-active')

    if @$nav.hasClass('search-active')
      @$searchInput.select()
    else
      @$searchInput.val('').trigger('search')

  search: (e) =>
    val = @$searchInput.val()
    return unless val

    Post.search.query(val)
    State.set(sidebar: 'search')

  # Keybindings

  isActiveArea: ->
    @$el.isActiveArea()

  upKey: (e) =>
    return unless @isActiveArea()
    e.preventDefault()
    @previousPost()

  downKey: (e) =>
    return unless @isActiveArea()
    e.preventDefault()
    @nextPost()

  jKey: (e) =>
    e.preventDefault()
    @nextPost()

  kKey: (e) =>
    e.preventDefault()
    @previousPost()

  keyMapping:
    38: 'upKey'
    40: 'downKey'
    74: 'jKey'
    75: 'kKey'

  keydown: (e) =>
    # Return if input
    return if 'value' of e.target

    # Are we listening for this key?
    mapping = @[@keyMapping[e.which]]
    return unless mapping

    mapping(e)

  # Cleanup global events

  release: =>
    $(window).off('keydown', @keydown)
    $(document).off('wake', @refresh)

module.exports = Sidebar