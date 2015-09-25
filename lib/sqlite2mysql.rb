require 'mysql2'
require 'sqlite3'

require 'sqlite2mysql/version'
require 'sqlite2mysql/services/mysql'
require 'sqlite2mysql/services/sqlite'

puts 'WARNING: Including sqlite2mysql does nothing, run it from the terminal.'

class Sqlite2Mysql
  class << self
    def run(args)
      do_everything(args)
      1
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

      mysql = MysqlClient.new(host: 'localhost', username: 'root')
      mysql.recreate(sql_db_name)

      schema.keys.each do |table|
        puts "Creating table: #{table}"
        mysql.create_table(table, schema[table])
      end

      print 'Grab a ☕' # ============================================================

      schema.keys.each do |table|
        puts "\nInserting data: #{table}"
        data = db.execute("select * from #{table}")
        mysql.insert_table(table, data)
      end
      puts ''
    end
  end
end
