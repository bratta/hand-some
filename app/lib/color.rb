class Color
  attr_accessor :id, :code
  def initialize(id, code)
    @id = id.nil? ? 0 : id
    @code = code.nil? ? [0,0,0,0] : code
  end

  White = [255,255,255,255]
  Cyan = [121,251,254,255]
  Orange = [236,137,32,255]
  Blue = [29,0,251,255]
  Yellow = [254,255,56,255]
  Red = [230,53,20,255]
  Purple = [232,47,251,255]
  Green = [122,252,51,255]
  Black = [0,0,0,255]
  Gray = [200,200,200,255]
  DarkGray = [10,10,10,255]
end