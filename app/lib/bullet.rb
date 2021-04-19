class Bullet < Sprite
  attr_rect
  attr_accessor :speed, :max_height, :hit_target

  def initialize(opts)
    @x = opts[:x] || 0
    @y = opts[:y] || 0
    @w = opts[:w] || 100
    @h = opts[:h] || 25
    @path = opts[:path] || 'sprites/rainbow-laser.png'
    @speed = opts[:speed] || 8
    @max_height = opts[:max_height] || 400
    @hit_target = false
  end

  def serialize
    { x: @x, y: @y, w: @w, h: @h, path: @path, speed: @speed, max_height: @max_height, hit_target: false }
  end
end