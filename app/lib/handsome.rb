# This game slaps
class Handsome
  def initialize(args)
    @args = args

    @field_minimum_x = 320
    @field_maximum_x = 960

    @player = Player.new(args: @args)
    @health = Health.new(args)
    @player.set_field_dimensions(@field_minimum_x, @field_maximum_x)
    @input_manager = InputManager.new(args)
    @soundboard = Soundboard.new(args: @args)
    @starfield = Starfield.new(args)
    @show_fps = true
    @explosions = []

    reset_game

    @game_state = :title

    # TODO: Load this from JSON
    @quotes = [
      'All your base are belong to us.',
      '"Where there\'s a will, there\'s a beneficiary." - The 8th Doctor',
      'Shall we play a game? How about global thermonuclear war?',
      'I only know 25 letters of the alphabet. I don\'t know Y.',
      'Don\'t trust trees; they can be shady.',
      'Eating clocks is very time consuming.',
      'LEEEEROY JEEEENKINS!',
      'I am one giant meat-based NFT.',
      'Ruby is not a dead language.',
      '"I never forget a face, but in your case I\'ll be glad to make an exception." - Groucho Marx',
      '"I\'ve had a perfectly wonderful evening. But this wasn\'t it." - Groucho Marx',
      '"Time flies like an arrow. Fruit flies like a banana." - Groucho Marx',
      '"We all make choices in life, but in the end our choices make us." - Andrew Ryan',
      '"Bring me a bucket, and I\'ll show you a bucket!" - Psycho',
      '"..." - Many JRPG protagonists',
      '"Nothing is true, everything is permitted." - Ezio',
      '"NOTHING IS MORE BADASS THAN TREATING A WOMAN WITH RESPECT!" - Mr. Torgue',
      'War. War never changes.',
      '"Stay awhile, and listen!" - Deckard Cain',
      '"We both said a lot of things that you\'re going to regret." - GLaDOS'
    ]
    @quote = @quotes.sample
  end

  def serialize
    { field_minimum_x: @field_minimum_x, field_minimum_y: @field_maximum_y, show_fps: @show_fps, game_state: @game_state }
  end

  ###########################
  # Here's the main game loop
  ###########################
  def tick
    handle_input

    case @game_state
    when :title
      render_title
    when :game
      if @player.health <= 0
        @game_state = :game_over
      else
        render
      end
    when :game_over
      render_game_over
    else
      exit(0)
    end
  end

  #########################################
  # Set up our input events based on the
  # buttons configured in the input manager
  #########################################
  def handle_input
    case @game_state
    when :title, :game_over
      @input_manager.handle_down_init do
        reset_game
        @game_state = :game
      end
    when :game
      @input_manager.handle_held_left do
        @player.move_left
      end
      @input_manager.handle_held_right do
        @player.move_right
      end
      @input_manager.handle_held_down do
        @starfield.direction = 0
      end
      @input_manager.handle_down_space do
        @player.firing = true
        @player.fire_bullet
      end
      @input_manager.handle_up_space do
        @player.firing = false
      end
      @input_manager.handle_up_down do
        @starfield.direction = -1
      end
    end
  end

  #############################################
  # Calling $gtk.reset is clunky. This properly
  # reset state to where it should be
  #############################################
  def reset_game
    @score = 0
    @level = 1
    @baddies_per_level = 15
    @player.health = @player.max_health
    @player.firing = false
    @player.bullets = []
    @starfield.direction = -1
    randomize_baddie_timer
    initialize_baddies
  end

  ################################################
  # This is the black background and gray sidebars
  ################################################
  def render_playing_field
    @args.outputs.solids << [ 0, 0, 1280, 720, *Color::Black ]
    @args.outputs.solids << [ 0, 0, @field_minimum_x-1, 720, *Color::DarkGray ]
    @args.outputs.solids << [ @field_maximum_x+1, 0, 1280, 720, *Color::DarkGray ]
  end

  ############
  # Health bar
  ############
  def render_health
    @health.percentage = @player.health.to_f / @player.max_health.to_f
    @health.render
  end

  ########################
  # Title screen and music
  ########################
  def render_title
    @soundboard.loop_title
    @args.outputs.sprites << {
      x: 0,
      y: 0,
      w: 1280,
      h: 720,
      path: 'sprites/new-game.png'
    }
    @args.outputs.labels << [ 640, 100, @quote, 1, 1, *Color::White ]
  end

  #####################################################################
  # MAIN RENDER LOOP
  # This is responsible for drawing all the game elements on the screen
  # for each tick of the game
  #####################################################################
  def render
    @soundboard.stop_title
    @soundboard.stop_gameover
    @soundboard.loop_level
    render_playing_field
    @starfield.render
    @player.render
    render_health
    render_fps
    render_score
    render_baddies
    calculate_bullets
    detect_collision
    explode
    render_explosions
    level_up
  end

  #########################################
  # Remove any exploded baddies and bullets
  #########################################
  def explode
    @baddies[:shown].reject! do |baddie|
      baddie.exploded
    end
    @player.bullets.reject! do |bullet|
      bullet.hit_target
    end
  end

  ##################################################################
  # When all baddies are defeated, give a score, increase the level,
  # and spawn in more baddies to defeat.
  ##################################################################
  def level_up
    if @baddies[:shown].length == 0 && @baddies[:staged].length == 0
      @score += 500
      @level += 1
      initialize_baddies
    end
  end

  #####################################################################
  # DragonRuby has cool rectangle geometry methods that make detecting
  # collisions easy without necessarily needing a collider object and
  # calculating vectors. Here we are looking for intersections of the
  # player with a baddie ship.
  #####################################################################
  def detect_collision
    @baddies[:shown].each do |baddie|
      if baddie.intersect_rect? @player
        baddie.loop_baddie
        @player.health -= 1
        @soundboard.play_oof
      end
    end
  end

  #####################################################################
  # Similarly, we calculate collisions of rainbow bullets to baddies
  # here, and if so we increase the score, add a new explosion loop,
  # and play the sound. Other rendering methods will look at the state
  # of the objects and remove them as needed.
  #####################################################################
  def calculate_bullets
    @player.bullets.each do |bullet|
      @baddies[:shown].each do |baddie|
        if bullet.intersect_rect? baddie
          baddie.exploded = true
          bullet.hit_target = true
          @score += 100
          @explosions << Explosion.new(args: @args, x: baddie.x, y: baddie.y)
          @soundboard.play_explosion
        end
      end
    end
  end

  #############################
  # Show the "Game Over" screen
  #############################
  def render_game_over
    @soundboard.stop_level
    @soundboard.loop_gameover
    @args.outputs.sprites << {
      x: 0,
      y: 0,
      w: 1280,
      h: 720,
      path: 'sprites/game-over.png'
    }
    @args.outputs.labels << [ 640, 100, "SCORE: #{@score}", 3, 1, *Color::White ]
  end

  ########################
  # Who doesn't want this?
  ########################
  def render_fps
    fps = @args.gtk.current_framerate.round
    if @show_fps
      @args.outputs.labels << [ 25, 710, "FPS: #{fps}", -4, 0, *Color::White ]
    end
  end

  #####################################################################
  # TODO: Make the "level" display better
  # This could use some love. The "Score" part is fine, but the "Level"
  # is somewhat lacking.
  #####################################################################
  def render_score
    @args.outputs.labels << [ 90, 80, "Level: #{@level}", -3, 0, *Color::White ]
    @args.outputs.labels << [ 90, 65, "Score: #{@score}", -3, 0, *Color::White ]
  end

  #####################################################################
  # Since each tick is 60 seconds, this will give a random wait for new
  # baddies with a time range of 1-6 seconds.
  #####################################################################
  def randomize_baddie_timer
    @baddie_randomizer = rand(60*5) + 60
  end

  ####################################################################
  # Separate baddies into two queues: They start off in staged but
  # will move over to be shown in batches based on level and the time
  # randomized in the baddie timer.
  ####################################################################
  def initialize_baddies
    @baddies = {
      staged: [],
      shown: []
    }
    0..(@level * @baddies_per_level).times do
      x = rand(@field_maximum_x - @field_minimum_x - 100) + @field_minimum_x
      speed = rand(6) + 3 + @level
      @baddies[:staged] << Baddie.new(x: x, y: 720, speed: speed)
    end
  end

  ########################################################################
  # Show baddies based on the level, timer, and remaining baddies to show
  # in this level
  ########################################################################
  def render_baddies
    if @starfield.direction != 0
      @baddie_randomizer -= 1
      if @baddie_randomizer == 0
        0..@level.times do
          @baddies[:shown] << @baddies[:staged].pop if @baddies[:staged].length > 0
        end
        randomize_baddie_timer
      end
    end
    @args.outputs.labels << [ 25, 690, "Baddies: #{@baddies[:staged].length}/#{@baddies[:shown].length}", -4, 0, *Color::White ]
    @baddies[:shown].each do |baddie|
       baddie.calculate_position
       @args.outputs.sprites << baddie
    end
  end

  ###################################################################################
  # Call render on any explosions after removing explosion objects that are finished
  ###################################################################################
  def render_explosions
    @explosions.reject! do |explosion|
      explosion&.done
    end
    @explosions.each do |explosion|
      explosion&.render
    end
  end
end