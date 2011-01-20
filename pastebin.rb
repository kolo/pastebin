require 'bundler/setup'
Bundler.require(:default)
Bundler.require(Sinatra::Base.environment)

APP_PATH = File.expand_path(File.dirname(__FILE__))

if File.exists?('config.yml')
  @config = YAML.load(File.read('config.yml'))[Sinatra::Base.environment.to_s]
else
  puts 'Config file is empty. Using empty configuration.'
  @config = {}
end

require 'db/initialize'

Syntaxes = {
  "plain"      => "Plain Text",
  "cplusplus"  => "C++",
  "java"       => "Java",
  "javascript" => "Javascript",
  "ruby"       => "Ruby"
}

Extensions = {
  "plain"      => ".txt",
  "cplusplus"  => ".cpp",
  "java"       => ".java",
  "javascript" => ".js",
  "ruby"       => ".rb"
}

class Pastebin < Sinatra::Base
  configure do
    Compass.configuration do |config|
      config.project_path = File.dirname(__FILE__)
    end

    set :haml, { :format => :html5 }
    set :sass, Compass.sass_engine_options

    set :logging, true
  end

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
          :raw_content => params['content'],
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

  get '/:id/download' do
    @pastie = Pastie.first(:id => params['id'])
    if @pastie
      filename = File.join(APP_PATH, 'files', get_filename(@pastie))
      unless File.exists?(filename)
        File.open(filename, 'w'){|f| f.write(@pastie.raw_content)}
      end
      send_file(filename, :disposition => 'attachment', :filename => File.basename(filename))
    else
      redirect '/'
    end
  end

  get '/:id/raw' do
    @pastie = Pastie.first(:id => params['id'])
    if @pastie
      haml :raw, :layout => false
    else
      redirect '/'
    end
  end

  def get_filename(pastie)
    pastie.id.to_s + Extensions[pastie.syntax]
  end
end
