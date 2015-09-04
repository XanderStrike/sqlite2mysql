require 'mysql2'
require 'sqlite3'

DATABASE = 'test.db'

# don't change this
SQL_DB_NAME = DATABASE.gsub(/[^0-9a-z]/i, '')

# ~~~ gather sqlite info ~~~
puts 'Collecting Sqlit3 Info'
db = SQLite3::Database.new DATABASE

schema = {}

tables = db.execute 'SELECT name FROM sqlite_master WHERE type="table"'

tables.flatten.each do |t|
  columns = db.execute("pragma table_info(#{t})")

  formatted_columns = []
  columns.each do |col|
    formatted_columns << [col[1], # name
                          col[2], # type
                          col[4]] # default
  end

  schema[t] = formatted_columns
end

# ~~~ build mysql db ~~~
puts "Creating MySQL DB: #{SQL_DB_NAME}"

def create_table_query(table, columns)
  query = "CREATE TABLE #{table} ("
  cols = []
  columns.each do |col|
    cols << "#{col[0]} #{col[1] == "" ? 'varchar(255)' : col[1]}"
  end
  query + "#{cols.join(', ')})"
end

client = Mysql2::Client.new(host: 'localhost', username: 'root')

client.query("DROP DATABASE IF EXISTS #{SQL_DB_NAME}")
client.query("CREATE DATABASE #{SQL_DB_NAME}")
client.query("USE #{SQL_DB_NAME}")

schema.keys.each do |table|
  puts "Creating table: #{table}"
  client.query(create_table_query(table, schema[table]))
end

# ~~~ populate mysql ~~~
print 'Grab a ☕'
schema.keys.each do |table|
  puts "\nInserting data: #{table}"
  data = db.execute("select * from #{table}")
  data.each_slice(1000) do |slice|
    print '.'
    slice.each do |row|
      client.query("INSERT INTO #{table} VALUES (\"#{row.join('", "')}\")")
    end
  end
end
puts ''
