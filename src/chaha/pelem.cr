class Pelem
  property digit
  property digit_count
  property da_next

  @da_next : Pelem?

  def initialize()
    # i'd call reset instead but the compiler complains that
    # i'm not initializing the following if i do
    @digit = Array(Int8?).new(8, Int8.new(0))
    @digit_count = Int8.new(0);
  end

  def initialize(clone : Pelem)
    @digit = clone.digit
    @digit_count = clone.digit_count
  end

  def reset
    @digit = Array(Int8?).new(8, Int8.new(0))
    @digit_count = 0;
    @da_next = nil.as(Pelem?)
  end

end


