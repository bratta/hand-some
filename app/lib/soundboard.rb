class Soundboard
  attr_accessor :effects, :loops

  def initialize(opts)
    @args = opts[:args]
    @effects = opts[:effects] || {
      explosion: { input: 'sounds/explosion.wav' },
      oof: { input: 'sounds/oof.wav' }
    }
    @loops = opts[:loops] || {
      level: { input: 'sounds/fear-of-failure.ogg' },
      title: { input: 'sounds/hiss-boom.ogg' },
      gameover: { input: 'sounds/coming-to-terms.ogg' }
    }

    @commands = [:play, :loop, :stop]
  end

  def play_loop(loop_name)
    if @loops[loop_name]
      return if @args.audio[loop_name]
      loop = @loops[loop_name]
      @args.audio[loop_name] = {
        input: loop[:input],
        x: 0,
        y: 0,
        z: 0,
        gain: 1.0,
        pitch: 1.0,
        paused: false,
        looping: true
      }
    end
  end

  def play_effect(effect_name)
    if @effects[effect_name]
      effect = @effects[effect_name]
      @args.audio[effect_name] = {
        input: effect[:input],
        x: 0,
        y: 0,
        z: 0,
        gain: 1.0,
        pitch: 1.0,
        paused: false,
        looping: false
      }
    end
  end

  def stop_sound(sound_name)
    @args.audio.delete(sound_name)
  end

  # Allow for method invocations such as "soundboard.play_explosion" or "soundboard.loop_title"
  def method_missing(m, *args, &block)
    mapping = m.to_s.split('_')
    if mapping && mapping.length == 2 && @commands.include?(mapping[0].to_sym)
      command, audio = mapping[0].to_sym, mapping[1].to_sym
      command_method = ''
      if command == :play
        command_method = :play_effect
      elsif command == :loop
        command_method = :play_loop
      elsif command == :stop
        command_method = :stop_sound
      end
      send(command_method, audio)
    end
  end
end