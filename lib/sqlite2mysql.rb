require 'sqlite2mysql/version'
require 'sqlite2mysql/services/arguments'
require 'sqlite2mysql/services/bound_finder'
require 'sqlite2mysql/services/mysql'
require 'sqlite2mysql/services/sqlite'
require 'sqlite2mysql/services/type_inferrer'

class Sqlite2Mysql
  class << self
    def run(args)
      arguments = Arguments.new(args)

      puts 'Collecting Sqlite3 Info'

      db = SqliteClient.new(arguments.sqlite_db, infer_column_types: arguments.infer_types)

      schema = db.build_schema

      puts "Creating MySQL DB: #{arguments.mysql_db}"

      mysql = MysqlClient.new(
        host:     arguments.mysql_host,
        username: arguments.username,
        password: arguments.password,
        port:     arguments.mysql_port)
      mysql.recreate(arguments.mysql_db)
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
