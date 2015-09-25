require 'sqlite3'

class SqliteClient
  def initialize(filename)
    @db = SQLite3::Database.new(filename)
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
                             type:    col[2],
                             notnull: col[3],
                             default: col[4] }
    end
    formatted_columns
  end
end
