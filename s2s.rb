require 'mysql2'
require 'sqlite3'

DATABASE = 'test.db'

# don't change this
FORMATTED_DATABASE = DATABASE.gsub(/[^0-9a-z]/i, '')

# ~~~ gather sqlite info ~~~
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
def create_table_query(table, columns)
  query = "CREATE TABLE #{table} ("
  cols = []
  columns.each do |col|
    cols << "#{col[0]} #{col[1] == "" ? 'varchar(255)' : col[1]}"
  end
  query + "#{cols.join(', ')})"
end

client = Mysql2::Client.new(host: 'localhost', username: 'root')
client.query("DROP DATABASE IF EXISTS #{FORMATTED_DATABASE}")
client.query("CREATE DATABASE #{FORMATTED_DATABASE}")
client.query("USE #{FORMATTED_DATABASE}")
schema.keys.each do |table|
  client.query(create_table_query(table, schema[table]))
end

# ~~~ populate mysql ~~~
