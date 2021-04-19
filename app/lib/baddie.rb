class Baddie < Sprite
  attr_rect
  attr_accessor :exploded

  def initialize(opts)
    @x = opts[:x]
    @y = opts[:y]
    @w = opts[:w] || 100
    @h = opts[:h] || 69
    @path = opts[:path] || 'sprites/spaceship1.png'
    @speed = opts[:speed] || 1.2
    @exploded = opts[:exploded] || false
  end

  def calculate_position
    @y -= @speed
    loop_baddie if @y < 0
  end

  def loop_baddie
    @y = 720
  end

  def serialize
    { x: @x, y: @y, w: @w, h: @h, path: @path, speed: @speed, exploded: @exploded }
  end
end