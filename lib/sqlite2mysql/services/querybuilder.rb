module QueryBuilder
  def create_table_query(table, columns)
    reserved_words = %w(key int)
    query = "CREATE TABLE #{table} ("
    cols = []
    columns.each do |col|
      col[:name] += '_1' if reserved_words.include?(col[:name])
      if col[:type] == ''
        col[:type] = 'varchar(255)'
      elsif col[:type].start_with?('float')
        col[:type] = 'float'
      end
      cols << "#{col[:name]} #{col[:type]} #{'NOT NULL' if col[:notnull]}"
    end
    query + "#{cols.join(', ')})"
  end
end
