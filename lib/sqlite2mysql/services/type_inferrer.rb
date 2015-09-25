class TypeInferrer
  def initialize(samples)
    @samples = samples
  end

  def make_inference
    possibilities = weigh_possibilities

    top = 0
    most_likely = :string
    possibilities.keys.each do |k|
      if possibilities[k] > top
        most_likely = k
        top = possibilities[k]
      end
    end

    case most_likely
    when :int
      return 'INT'
    when :float
      return 'FLOAT'
    when :datetime
      return 'DATETIME'
    when :string
      return 'VARCHAR(255)'
    end
  end

  def weigh_possibilities
    {
      float: 0,
      int: 0,
      datetime: 0,
      string: 0
    }.tap do |possibilities|
      @samples.each do |sample|
        if sample.is_a?(Date) || sample.is_a?(Time) || sample.is_a?(String) && %r((\d{1,2}[-\/]\d{1,2}[-\/]\d{4})|(\d{4}[-\/]\d{1,2}[-\/]\d{1,2})).match(sample)
          possibilities[:datetime] += 1
        elsif sample.is_a?(Float) || sample.to_i > 0 && sample.to_f != sample.to_i.to_f
          possibilities[:float] += 1
        elsif sample.is_a?(Integer) || sample.to_i > 0 || sample == '0'
          possibilities[:int] += 1
        else
          possibilities[:string] += 1
        end
      end
    end
  end
end
