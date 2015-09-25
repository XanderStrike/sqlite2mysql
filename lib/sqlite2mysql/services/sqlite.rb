require 'sqlite3'
require 'time'

class SqliteClient
  def initialize(filename, infer_column_types: false)
    @db = SQLite3::Database.new(filename)
    @infer = infer_column_types
  end

  def build_schema
    schema = {}
    tables = @db.execute 'SELECT name FROM sqlite_master WHERE type="table"'

    tables.flatten.each do |t|
      schema[t] = column_formatter(t)
    end

    schema
  end

  def get_data(table)
    @db.execute("select * from #{table}")
  end

  def column_formatter(table)
    columns = @db.execute("pragma table_info(#{table})")

    formatted_columns = []
    columns.each do |col|
      formatted_columns << { name:    col[1],
                             type:    type_getter(col[2], table, col[1]),
                             notnull: col[3],
                             default: col[4] }
    end
    formatted_columns
  end

  def type_getter(type, table, column)
    if @infer
      type = infer_type_of(column, table)
      puts "Inferring type of #{column} as #{type}"
      return type
    else
      if type == ''
        return 'varchar(255)'
      elsif type.start_with?('float')
        return 'float'
      end
    end
  end

  def infer_type_of(column, table)
    samples = @db.execute("SELECT #{column} FROM #{table} WHERE #{column} IS NOT NULL ORDER BY RANDOM() LIMIT 100;").flatten
    possibilities = {
      float: 0,
      int: 0,
      datetime: 0,
      string: 0
    }
    samples.each do |sample|
      if (Time.parse(sample) rescue false)
        possibilities[:datetime] += 1
      elsif sample.is_a?(Float) || sample.to_i > 0 && sample.to_f != sample.to_i.to_f
        possibilities[:float] += 1
      elsif sample.is_a?(Integer) || sample.to_i > 0 || sample == '0'
        possibilities[:int] += 1
      else
        possibilities[:string] += 1
      end
    end

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
end
