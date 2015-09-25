require 'mysql2'

class MysqlClient
  def initialize(host:, username:)
    @client = Mysql2::Client.new(host: host, username: username)
  end

  def recreate(name)
    @client.query("DROP DATABASE IF EXISTS #{name}")
    @client.query("CREATE DATABASE #{name}")
    @client.query("USE #{name}")
  end

  def build_from_schema(schema)
    schema.keys.each do |table|
      puts "Creating table: #{table}"
      create_table(table, schema[table])
    end
  end

  def create_table(table, fields)
    @client.query(create_table_query(table, fields))
  end

  def insert_table(table, data)
    data.each_slice(1000) do |slice|
      @client.query(chunk_sql(table, slice))
      print '.'
    end
  end

  private

  def chunk_sql(table, chunk)
    values = []
    chunk.each do |row|
      values << "#{row_sql(row)}"
    end
    "INSERT INTO #{table} VALUES #{values.join(', ')}"
  end

  def row_sql(row)
    values = row.map do |val|
      if val.is_a?(String)
        (val.empty? || val.nil? || val == '') ? nil : @client.escape(val)
      else
         val
      end
    end
    "(\"#{values.join('", "')}\")"
  end

  def create_table_query(table, fields)
    reserved_words = %w(key int)
    query = "CREATE TABLE #{table} ("
    cols = []
    fields.each do |col|
      col[:name] += '_1' if reserved_words.include?(col[:name])
      cols << "#{col[:name]} #{col[:type]} #{'NOT NULL' if col[:notnull]}"
    end
    query + "#{cols.join(', ')})"
  end
end
