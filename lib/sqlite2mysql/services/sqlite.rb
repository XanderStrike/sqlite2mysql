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
      samples = @db.execute("SELECT #{column} FROM #{table} WHERE #{column} IS NOT NULL AND #{column} != '' ORDER BY RANDOM() LIMIT 100").flatten
      type = TypeInferrer.new(samples, BoundFinder.new(self, table, column)).make_inference
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

  def select(column, table)
    @db.execute("SELECT #{column} FROM #{table}").flatten.first
  end
end
