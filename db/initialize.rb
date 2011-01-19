# Heroku uses DATABASE_URL environment variable to pass database path to the app
if ENV['DATABASE_URL']
  @config['database'] = ENV['DATABASE_URL']
end

case @config['db_adapter']
when 'sqlite3'
  DataMapper.setup(:default, "sqlite:///#{APP_PATH}/#{@config['database']}")
when 'mysql'
  DataMapper.setup(:default, "mysql://#{@config['database']}")
else
  puts "Doesn't know how to handle #{@config['db_adapter']} database type"
  exit
end

require 'models/pastie'

DataMapper.finalize

case @config['db_adapter']
when 'sqlite3'
  if File.exists?("#{APP_PATH}/#{@config['database']}")
    DataMapper.auto_upgrade!
  else
    DataMapper.auto_migrate!
  end
when 'mysql'
  DataMapper.auto_upgrade!
else 
  puts "Doesn't know how to handle #{@config['db_adapter']} database type"
  exit
end
