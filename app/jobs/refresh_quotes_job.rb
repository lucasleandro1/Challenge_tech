class RefreshQuotesJob
  include Sidekiq::Job

  def perform
    TagCache.all.each do |tag_cache|
      quotes = CrawlerService.new(tag_cache.name).call
      next if quotes.empty?

      new_quotes = quotes.reject do |q|
        tag_cache.quotes.any? { |existing| existing["quote"] == q["quote"] }
      end

      tag_cache.push(quotes: new_quotes) if new_quotes.any?
    end
  end
end
