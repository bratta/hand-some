class Explosion < Sprite
  attr_rect
  attr_accessor :frames_in_sheet, :ticks_per_frame, :done

  def initialize(opts)
    @args = opts[:args]
    @x = opts[:x]
    @y = opts[:y]
    @w = opts[:w] || 128
    @h = opts[:h] || 128
    @path = opts[:path] || 'sprites/explosion.png'
    @frames_in_sheet = opts[:frames_in_sheet] || 8
    @ticks_per_frame = opts[:ticks_per_frame] || 10
    @done = false
  end

  def serialize
    { x: @x, y: @y, w: @w, h: @h, path: @path, fames_in_sheet: @frames_in_sheet, ticks_per_frame: @ticks_per_frame, done: @done }
  end

  def render
    start_exploding_at = 0
    tile_index = start_exploding_at.frame_index(@frames_in_sheet, @ticks_per_frame, true)
    @done = true if tile_index >= @frames_in_sheet - 1
    @args.outputs.sprites << {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      path: @path,
      tile_x: 0 + (tile_index * @w),
      tile_y: 0,
      tile_w: @w,
      tile_h: @h
    }
  end
end