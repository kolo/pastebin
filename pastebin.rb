require 'bundler'
Bundler.require(:default)

APP_PATH = File.expand_path(File.dirname(__FILE__))
$: << APP_PATH

case Sinatra::Base.environment
when :development
  Bundler.require(:development)
when :production
  Bundler.require(:production)
end

if File.exists?('config.yml')
  @config = YAML.load(File.read('config.yml'))[Sinatra::Base.environment.to_s]
else
  puts 'Config file is empty. Using empty configuration.'
  @config = []
end

configure do
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
  end

  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options
end

require 'db/initialize'

Syntaxes = {
  "plain"      => "Plain Text",
  "cplusplus"  => "C++",
  "java"       => "Java",
  "javascript" => "Javascript",
  "ruby"       => "Ruby"
}

get '/css/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss(:"scss/#{params[:name]}", Compass.sass_engine_options )
end

get '/' do
  haml :index
end

post '/create' do
  if params['syntax'] && params['content']
    begin
      created_at = Time.now
      pastie = Pastie.create(
        :syntax      => params['syntax'],
        :content     => CodeRay.scan(params['content'], params['syntax']).div(:css => :class, :line_numbers => :table),
        :created_at  => created_at
      )
      redirect "/#{pastie.id}"
    rescue Exception => e
      redirect '/'
    end
  end
end

get '/favicon.ico' do
  ""
end

get '/:id' do
  @pastie = Pastie.first(:id => params['id'])
  if @pastie
    haml :pastie
  else
    redirect '/'
  end
end
