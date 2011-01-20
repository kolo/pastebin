class Pastie
  include DataMapper::Resource

  property :id,          Serial
  property :syntax,      String
  property :raw_content, Text
  property :content,     Text
  property :created_at,  DateTime
end
