class QuoteFetcherService
  def initialize(tag)
    @tag = tag.downcase
  end

  def call
    cached = TagCache.find_by(name: @tag)

    if cached&.quotes&.any?
      cached.quotes
    else
      fetch_and_cache(cached)
    end
  end

  private

  def fetch_and_cache(cached)
    quotes = CrawlerService.new(@tag).call

    if cached
      cached.update(quotes: quotes)
    else
      TagCache.create(name: @tag, quotes: quotes)
    end

    quotes
  end
end
