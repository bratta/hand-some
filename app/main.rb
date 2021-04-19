$gtk.reset

require 'app/lib/color.rb'
require 'app/lib/sprite.rb'
require 'app/lib/soundboard.rb'
require 'app/lib/health.rb'
require 'app/lib/bullet.rb'
require 'app/lib/explosion.rb'
require 'app/lib/baddie.rb'
require 'app/lib/player.rb'
require 'app/lib/starfield.rb'
require 'app/lib/input_manager.rb'
require 'app/lib/handsome.rb'

# Start the main game loop
def tick args
  args.state.game ||= Handsome.new(args)
  args.state.game.tick
end
