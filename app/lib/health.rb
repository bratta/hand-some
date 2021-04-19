class Health
  attr_accessor :percentage
  def initialize(args, x=28, y=5, percentage=1)
    @args = args
    @x, @y, @percentage = x, y, percentage
    @sprite = 'sprites/health-bar.png'
  end

  def render
    @percentage = 1.0 if @percentage > 1.0
    @percentage = 0.0 if @percentage <= 0.0
    # Health box dimensions are (205, 30)
    width = 205 * @percentage
    height = 25
    @args.outputs.solids << [ @x+55, @y+15, width, height, *Color::Red ]
    @args.outputs.sprites << {
      x: @x,
      y: @y,
      w: 265,
      h: 50,
      path: @sprite
    }
  end
end