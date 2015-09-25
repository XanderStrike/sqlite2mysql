require 'spec_helper'

describe Arguments do
  describe '.initialize' do
    it 'gets the sqlite and mysql databases' do
      args = Arguments.new(['sqlite.db', 'mysql'])

      expect(args.mysql_db).to eq('mysql')
      expect(args.sqlite_db).to eq('sqlite.db')
    end

    it 'names the mysql db after the sqlite db if no mysql name provided' do
      args = Arguments.new(['path/to/sqlite.db'])

      expect(args.mysql_db).to eq('pathtosqlitedb')
    end

    it 'provides help text when no arguments or --help' do
      expect(STDOUT).to receive(:puts).with(/sqlite2mysql/).twice

      begin
        Arguments.new([])
      rescue SystemExit => e
        expect(e.status).to eq(0)
      end

      begin
        Arguments.new(['testdb', 'asdf', '--help'])
      rescue SystemExit => e
        expect(e.status).to eq(0)
      end
    end
  end

  describe '.infer' do
    it 'sets the infer setting to true' do
      args = Arguments.new(['test'])
      expect(args.infer_types).to eq(nil)

      args.infer([])
      expect(args.infer_types).to eq(true)
    end
  end

  describe '.user' do
    it 'sets the user' do
      args = Arguments.new(['test'])
      expect(args.username).to eq('root')

      args.user(['--user', 'xander'])
      expect(args.username).to eq('xander')
    end
  end

  describe '.pass' do
    it 'sets the password' do
      args = Arguments.new(['test'])
      expect(args.password).to eq(nil)

      args.pass(['--pass', 'hunter2'])
      expect(args.password).to eq('hunter2')
    end
  end

  describe '.port' do
    it 'sets the port' do
      args = Arguments.new(['test'])
      expect(args.mysql_port).to eq(nil)

      args.port(['--port', '3005'])
      expect(args.mysql_port).to eq('3005')
    end
  end

  describe '.host' do
    it 'sets the host' do
      args = Arguments.new(['test'])
      expect(args.mysql_host).to eq(nil)

      args.host(['--host', 'google.com'])
      expect(args.mysql_host).to eq('google.com')
    end
  end

  describe '.help' do
    it 'puts the help and exits' do
      args = Arguments.new(['test'])

      expect(STDOUT).to receive(:puts).with(/sqlite2mysql/)

      begin
        args.help([])
      rescue SystemExit => e
        expect(e.status).to eq(0)
      end
    end
  end
end
