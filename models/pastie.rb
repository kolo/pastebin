class Pastie
  include DataMapper::Resource

  property :id,         Serial
  property :syntax,     String
  property :content,    Text
  property :created_at, DateTime
end
