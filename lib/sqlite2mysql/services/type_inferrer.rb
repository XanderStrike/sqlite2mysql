class TypeInferrer
  def initialize(samples, bound_finder)
    @samples = samples
    @bound_finder = bound_finder
  end

  def make_inference
    possibilities = weigh_possibilities

    case possibilities.max_by { |k,v| v }.first
    when :int
      return get_integer_type
    when :float
      return 'FLOAT'
    when :date
      return 'DATE'
    when :datetime
      return 'DATETIME'
    when :string
      return get_varchar_type
    end
  end

  def weigh_possibilities
    {
      float: 0,
      int: 0,
      date: 0,
      datetime: 0,
      string: 0
    }.tap do |possibilities|
      @samples.each do |sample|
        if sample.is_a?(Date) || sample.is_a?(Time) || sample.is_a?(String) && %r((\d{1,2}[-\/]\d{1,2}[-\/]\d{4})|(\d{4}[-\/]\d{1,2}[-\/]\d{1,2})).match(sample)
          if sample.is_a?(Date) || Date.parse(sample).to_time == Time.parse(sample)
            possibilities[:date] += 1
          else
            possibilities[:datetime] += 1
          end
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

  def get_integer_type
    max = @bound_finder.max.to_i
    min = @bound_finder.min.to_i
    if min > -128 && max < 127
      'TINYINT'
    elsif min > -32768 && max < 32767
      'SMALLINT'
    elsif min > -8388608 && max < 8388607
      'MEDIUMINT'
    elsif min > -2147483648 && max < 2147483647
      'INT'
    else
      'BIGINT'
    end
  end

  def get_varchar_type
    max_length = @bound_finder.max_length
    max_length = 1 if max_length == 0 || max_length.nil?

    "VARCHAR(#{max_length})"
  end
end
