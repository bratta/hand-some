class InputManager
  def initialize(args)
    @args = args

    @keyboard = @args.inputs.keyboard
    @controller = @args.inputs.controller_one
    @valid_combos = ['held', 'down', 'up']

    # TODO: Load/Save configs from JSON
    # TODO: Have a few to customize button layouts
    @mappings = {
      held: {
        left:  { keyboard: :a,  controller: :left },
        right: { keyboard: :d,  controller: :right },
        up: { keyboard: :w, controller: :up },
        down: { keyboard: :s, controller: :down },
      },
      down: {
        space: { keyboard: :space, controller: :a },
        enter: { keyboard: :enter, controller: :b },
        init: { keyboard: :space, controller: :start }
      },
      up: {
        space: { keyboard: :space, controller: :a },
        up: { keyboard: :w, controller: :up },
        down: { keyboard: :s, controller: :down },
      },
    }
  end

  # Metaprogram the fuck out of this for the sake of a DSL
  def method_missing(m, *args, &block)
    mapping = m.to_s.split('_')
    if mapping && mapping.length == 3 && mapping[0] == 'handle' && @valid_combos.include?(mapping[1])
      combo, key = mapping[1], mapping[2]
      controls = @mappings[combo.to_sym][key.to_sym]
      if controls
        command = "key_#{combo}".to_sym
        if @keyboard.send(command)&.send(controls[:keyboard]) || @controller.send(command)&.send(controls[:controller])
          yield block
        end
      end
    end
  end
end