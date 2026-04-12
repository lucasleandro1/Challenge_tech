class CrawlerService
  SITE_URL = "http://quotes.toscrape.com"
  BASE_URL = "#{SITE_URL}/tag"

  def initialize(tag)
    @tag = tag
  end

  def call
    response = HTTParty.get("#{BASE_URL}/#{@tag}")

    unless response.success?
      Rails.logger.warn "CrawlerService: request failed for tag '#{@tag}' (HTTP #{response.code})"
      return []
    end

    parse(response.body)
  rescue HTTParty::Error, SocketError, Timeout::Error => e
    Rails.logger.error "CrawlerService: error fetching tag '#{@tag}' - #{e.class}: #{e.message}"
    []
  end

  private

  def parse(html)
    doc = Nokogiri::HTML(html)

    doc.css(".quote").map do |node|
      {
        "quote"        => node.css(".text").text.gsub(/\u201c|\u201d/, "").strip,
        "author"       => node.css(".author").text.strip,
        "author_about" => build_author_url(node),
        "tags"         => node.css(".tag").map(&:text)
      }
    end
  end

  def build_author_url(node)
    path = node.css("a").find { |a| a["href"]&.include?("/author/") }&.[]("href")
    path ? "#{SITE_URL}#{path}" : ""
  end
end
