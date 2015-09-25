class Arguments
  attr_accessor :mysql_host, :username, :password, :mysql_port, :infer_types,
                :mysql_db, :sqlite_db

  def initialize(args)
    help(args) if args.size == 0

    set_defaults
    unmodified_args = args.dup
    unmodified_args.each do |arg|
      if arg.start_with?('--')
        send(arg[2..-1], args)
        args.delete(arg)
      end
    end

    @sqlite_db = args.first
    @mysql_db = args[1] || @sqlite_db.gsub(/[^0-9a-z]/i, '')
  end

  def infer(_)
    @infer_types = true
  end

  def user(args)
    @username = get_value_for_flag('--user', args)
  end

  def pass(args)
    @password = get_value_for_flag('--pass', args)
  end

  def port(args)
    @mysql_port = get_value_for_flag('--port', args)
  end

  def host(args)
    @mysql_host = get_value_for_flag('--host', args)
  end

  def help(_)
    puts <<-HELP
Usage:
  sqlite2mysql sqlite.db [mysql_name]

Options:
  --help    Show this message
  --infer   Infer types for columns
  --user    MySQL username (default: root)
  --host    MySQL host     (default: localhost)
  --pass    MySQL password
  --port    MySQL port
HELP
    exit 0
  end

  private

  def get_value_for_flag(flag, args)
    index = args.index(flag)
    args.delete_at(index + 1)
  end

  def set_defaults
    @username = 'root'
    @password = nil
    @host = 'localhost'
    @port = nil
    @infer = false
  end
end
