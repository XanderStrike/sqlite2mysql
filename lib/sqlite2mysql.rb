require 'sqlite2mysql/version'
require 'sqlite2mysql/services/mysql'
require 'sqlite2mysql/services/sqlite'

puts 'WARNING: Including sqlite2mysql is silly, run it from the terminal.'

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

      puts 'Collecting Sqlite3 Info'

      db = SqliteClient.new database

      schema = db.build_schema

      puts "Creating MySQL DB: #{sql_db_name}"

      mysql = MysqlClient.new(host: 'localhost', username: 'root')
      mysql.recreate(sql_db_name)
      mysql.build_from_schema(schema)

      print 'Grab a ☕'

      schema.keys.each do |table|
        puts "\nInserting data: #{table}"
        data = db.get_data(table)
        mysql.insert_table(table, data)
      end
      puts ''
    end
  end
end
