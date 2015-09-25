require 'spec_helper'
describe Sqlite2Mysql do
  it 'does a thing' do
    Sqlite2Mysql.run(['spec/fixtures/test.db'])
  end
end
