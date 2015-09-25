class MYSQL
  def initialize(host:, username:)
    @client = Mysql2::Client.new(host: host, username: username)
  end

  def recreate(name)
    @client.query("DROP DATABASE IF EXISTS #{name}")
    @client.query("CREATE DATABASE #{name}")
    @client.query("USE #{name}")
  end

  def create_table(table, fields)
    @client.query(create_table_query(table, fields))
  end

  def insert_table(table, data)
    data.each_slice(1000) do |slice|
      slice.each do |row|
        cleaned_row = row.map do |val|
          val.is_a?(String) ? @client.escape(val) : val
        end
        @client.query("INSERT INTO #{table} VALUES (\"#{cleaned_row.join('", "')}\")")
      end
      print '.'
    end
  end

  private

  def create_table_query(table, fields)
    reserved_words = %w(key int)
    query = "CREATE TABLE #{table} ("
    cols = []
    fields.each do |col|
      col[:name] += '_1' if reserved_words.include?(col[:name])
      if col[:type] == ''
        col[:type] = 'varchar(255)'
      elsif col[:type].start_with?('float')
        col[:type] = 'float'
      end
      cols << "#{col[:name]} #{col[:type]} #{'NOT NULL' if col[:notnull]}"
    end
    query + "#{cols.join(', ')})"
  end
end
