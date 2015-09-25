require 'sqlite2mysql/version'

require 'mysql2'
require 'sqlite3'

puts 'WARNING: Including sqlite2mysql does nothing, run it from the terminal.'

require 'sqlite2mysql/services/querybuilder'

class Sqlite2Mysql
  class << self
    include QueryBuilder

    def run(args)
      do_everything(args)
    end

    def do_everything(args)
      puts 'Usage: sqlite2mysql sqlite_file.db [mysql_db_name]' if args.size < 1

      database = args.first
      sql_db_name = args[1] || database.gsub(/[^0-9a-z]/i, '')

      puts 'Collecting Sqlite3 Info' # ===============================================

      db = SQLite3::Database.new database

      schema = {}

      tables = db.execute 'SELECT name FROM sqlite_master WHERE type="table"'

      tables.flatten.each do |t|
        columns = db.execute("pragma table_info(#{t})")

        formatted_columns = []
        columns.each do |col|
          formatted_columns << { name:    col[1],
                                 type:    col[2],
                                 notnull: col[3],
                                 default: col[4] }
        end

        schema[t] = formatted_columns
      end

      puts "Creating MySQL DB: #{sql_db_name}" # ====================================

      client = Mysql2::Client.new(host: 'localhost', username: 'root')

      client.query("DROP DATABASE IF EXISTS #{sql_db_name}")
      client.query("CREATE DATABASE #{sql_db_name}")
      client.query("USE #{sql_db_name}")

      schema.keys.each do |table|
        puts "Creating table: #{table}"
        client.query(create_table_query(table, schema[table]))
      end

      print 'Grab a ☕' # ============================================================

      schema.keys.each do |table|
        puts "\nInserting data: #{table}"
        data = db.execute("select * from #{table}")
        data.each_slice(1000) do |slice|
          slice.each do |row|
            cleaned_row = row.map do |val|
              val.is_a?(String) ? client.escape(val) : val
            end
            client.query("INSERT INTO #{table} VALUES (\"#{cleaned_row.join('", "')}\")")
          end
          print '.'
        end
      end
      puts ''
    end
  end
end
