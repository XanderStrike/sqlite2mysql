class BoundFinder
  def initialize(client, table, column)
    @client = client
    @table = table
    @column = column
  end

  def max
    @client.select("MAX(#{@column})", @table)
  end

  def min
    @client.select("MIN(#{@column})", @table)
  end

  def max_length
    @client.select("MAX(LENGTH(#{@column}))", @table)
  end

  def min_length
    @client.select("MIN(LENGTH(#{@column}))", @table)
  end
end
