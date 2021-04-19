class Player < Sprite
  attr_rect
  attr_accessor :sprite, :health, :max_health, :firing, :bullets

  SPRITES = [
    'sprites/hand1.png',
    'sprites/hand2.png',
    'sprites/hand3.png',
  ]

  def initialize(opts)
    @args = opts[:args]
    @x = opts[:x] || 590 # (image width / 2)
    @y = opts[:y] || 1
    @w = opts[:w] || 100
    @h = opts[:h] || 105
    @max_health = opts[:health] || 10
    @health = @max_health
    @sprites = opts[:sprites] || SPRITES
    @path = opts[:path] || @sprites[0]
    @firing = false
    @bullets = opts[:bullets] || []
    @max_bullets = opts[:max_bullets] || 2

    @delta_x = 0  # No movement by default
    @delta_y = 0  # No movement by default
  end

  def serialize
    { x: @x, y: @y, w: @w, h: @h, path: @path, health: @health, firing: @firing, max_bullets: @max_bullets, bullets: @bullets.length }
  end

  def set_field_dimensions(min_x=nil, max_x=nil, min_y=nil, max_y=nil)
    @min_x = min_x || 0
    @max_x = (max_x || 1280) - @w
    @min_y = min_y || 0
    @max_y = (max_y || 720) - @h
  end

  def render
    calculate_new_position
    @args.outputs.sprites << {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      path: @sprites[get_sprite_index]
    }
    reset_deltas
    render_bullets
  end

  def render_bullets
    @bullets.reject! do |bullet|
      bullet.y += bullet.speed
      if (bullet.y >= 720 + bullet.h/2)
        true
      else
        bullet.h += bullet.speed
        bullet.h = bullet.max_height if bullet.h > bullet.max_height
        @args.outputs.sprites << bullet
        false
      end
    end
  end

  def fire_bullet
    @bullets << Bullet.new(x: @x, y: @y) if @bullets.length < @max_bullets
  end

  def calculate_new_position
    @x += @delta_x
    @x = @min_x if @x <= @min_x
    @x = @max_x if @x > @max_x

    @y += @delta_y
    @y = @min_y if @y <= @min_y
    @y = @max_y if @y > @max_y
  end

  def reset_deltas
    @delta_x, @delta_y = 0, 0
  end

  def move_left(delta=10)
    @delta_x = delta * -1
  end

  def move_right(delta=10)
    @delta_x = delta
  end

  def get_sprite_index
    return 2 if @firing
    if @delta_x != 0 || @delta_y != 0
      start_looping_at = 0
      number_of_sprites = 2
      number_of_frames_per_sprite = 30
      loop_sprites = true
      return start_looping_at.frame_index number_of_sprites, number_of_frames_per_sprite, loop_sprites
    else
      return 0
    end
  end
end