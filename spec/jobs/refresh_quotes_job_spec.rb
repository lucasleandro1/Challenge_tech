require 'rails_helper'

RSpec.describe RefreshQuotesJob do
  let(:existing_quote) { { "quote" => "Old quote", "author" => "Author", "author_about" => "", "tags" => [ "love" ] } }
  let(:new_quote)      { { "quote" => "New quote", "author" => "Author", "author_about" => "", "tags" => [ "love" ] } }

  before do
    TagCache.destroy_all
    TagCache.create!(name: "love", quotes: [ existing_quote ])
  end

  after { TagCache.destroy_all }

  it "adds new quotes without duplicating existing ones" do
    allow_any_instance_of(CrawlerService).to receive(:call).and_return([ existing_quote, new_quote ])

    described_class.new.perform

    tag_cache = TagCache.where(name: "love").first
    expect(tag_cache.quotes.size).to eq(2)
    expect(tag_cache.quotes.map { |q| q["quote"] }).to include("Old quote", "New quote")
  end

  it "does not update when crawler returns empty" do
    allow_any_instance_of(CrawlerService).to receive(:call).and_return([])

    described_class.new.perform

    tag_cache = TagCache.where(name: "love").first
    expect(tag_cache.quotes.size).to eq(1)
  end
end
