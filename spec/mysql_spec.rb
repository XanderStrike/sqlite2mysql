require 'spec_helper'
require 'mysql2'

describe MysqlClient do
  before :each do
    @client = double('client')
    expect(Mysql2::Client).to receive(:new).and_return(@client)
    @mysql = MysqlClient.new(host: 'test', username: 'test')
  end

  describe '.initialize' do
    it 'creates a mysql2 client' do
      expect(Mysql2::Client).to receive(:new).with(host: 'localhost', username: 'root')
      MysqlClient.new(host: 'localhost', username: 'root')
    end
  end

  describe '.recreate' do
    it 'dops, creates, and uses the new db' do
      expect(@client).to receive(:query).with('DROP DATABASE IF EXISTS testdb')
      expect(@client).to receive(:query).with('CREATE DATABASE testdb')
      expect(@client).to receive(:query).with('USE testdb')
      @mysql.recreate('testdb')
    end
  end

  describe 'insert_table' do
    it 'builds the query and inserts the data' do
      data = []
      5.times do |x|
        data << [x]
      end

      expect(@client).to receive(:query)
        .with('INSERT INTO testtable VALUES ("0"), ("1"), ("2"), ("3"), ("4")')

      @mysql.insert_table('testtable', data)
    end

    it 'slices the data into managable chunks' do
      data = []
      5000.times do |x|
        data << [x]
      end

      expect(@client).to receive(:query).exactly(5).times

      @mysql.insert_table('testtable', data)
    end
  end
end
