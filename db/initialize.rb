# Heroku uses DATABASE_URL environment variable to pass database path to the app
if ENV['DATABASE_URL']
  @config['database'] = ENV['DATABASE_URL']
end

if @config['database']
  DataMapper.setup(:default, @config['database'])
else
  puts 'Cannot work without database. Exit.'
  exit
end

require 'models/pastie'

DataMapper.finalize

if @config['database']
  case Sinatra::Base.environment
  when :development then DataMapper.auto_migrate!
  when :production then DataMapper.auto_upgrade!
  end
else
  puts 'Cannot work without database. Exit.'
  exit
end
