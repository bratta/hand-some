class Starfield
  attr_accessor :direction

  def initialize(args)
    @args = args
    @layers = [
      'sprites/starfield1.png',
      'sprites/starfield2.png',
      'sprites/starfield3.png',
      'sprites/starfield4.png',
      'sprites/starfield5.png'
    ]
    @delta_ys = @layers.map { 0 }
    @width = 640
    @height = 1440
    @relative_speed = 1.05
    @direction = -1 # 0 for no movement
  end

  # Fact: Lax parallax lets you relax, Jaques.
  def render
    @layers.each_with_index do |sprite, layer|
      @delta_ys[layer] += @direction * (@relative_speed * (layer+1))
      y = @delta_ys[layer] % (-1 * @height)
      y2 = y + @height
      @args.outputs.sprites << { x: 320, y: y, w: @width, h: @height, path: sprite }
      @args.outputs.sprites << { x: 320, y: y2, w: @width, h: @height, path: sprite }
    end
  end
end