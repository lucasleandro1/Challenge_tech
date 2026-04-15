require 'rails_helper'

RSpec.describe CrawlerService do
  let(:tag) { "love" }
  let(:html) do
    <<~HTML
      <div class="quote">
        <span class="text">\u201cThe world is a book.\u201d</span>
        <small class="author">Albert Einstein</small>
        <div class="tags">
          <a class="tag" href="/tag/love">love</a>
          <a class="tag" href="/tag/life">life</a>
        </div>
        <a href="/author/Albert-Einstein">about</a>
      </div>
    HTML
  end

  before do
    stub_request(:get, "http://quotes.toscrape.com/tag/#{tag}")
      .to_return(status: 200, body: html)
  end

  it "returns an array of quotes" do
    result = described_class.new(tag).call
    expect(result).to be_an(Array)
    expect(result.first["quote"]).to eq("The world is a book.")
    expect(result.first["author"]).to eq("Albert Einstein")
    expect(result.first["tags"]).to include("love", "life")
  end

  it "returns the author_about url" do
    result = described_class.new(tag).call
    expect(result.first["author_about"]).to eq("http://quotes.toscrape.com/author/Albert-Einstein")
  end

  context "when the request fails" do
    before do
      stub_request(:get, "http://quotes.toscrape.com/tag/#{tag}")
        .to_return(status: 404)
    end

    it "returns an empty array" do
      result = described_class.new(tag).call
      expect(result).to eq([])
    end
  end

  context "when a network error occurs" do
    before do
      stub_request(:get, "http://quotes.toscrape.com/tag/#{tag}")
        .to_raise(SocketError)
    end

    it "returns an empty array" do
      expect(described_class.new(tag).call).to eq([])
    end
  end
end
