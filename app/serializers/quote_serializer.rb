class QuoteSerializer
  def initialize(quote)
    @quote = quote
  end

  def as_json(*)
    {
      quote:        @quote["quote"],
      author:       @quote["author"],
      author_about: @quote["author_about"],
      tags:         @quote["tags"]
    }
  end
end
