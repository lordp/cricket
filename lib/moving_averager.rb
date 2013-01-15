class MovingAverager
  def initialize(size)
    @size = size
    @nums = []
    @sum = 0.0
  end
  def <<(hello)
    @nums << hello
    goodbye = @nums.length > @size ? @nums.shift : 0
    @sum += hello - goodbye
    self
  end
  def average
    @sum / @nums.length
  end
  alias to_f average
  def to_s
    average.to_s if @nums.length == @size
  end
end
