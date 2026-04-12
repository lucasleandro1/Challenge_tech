require 'rails_helper'

RSpec.describe QuoteFetcherService do
  let(:tag) { "love" }
  let(:quotes) { [{ "quote" => "A quote", "author" => "Someone", "author_about" => "", "tags" => ["love"] }] }

  context "when tag is cached with quotes" do
    before do
      TagCache.destroy_all
      TagCache.create!(name: tag, quotes: quotes)
    end

    after { TagCache.destroy_all }

    it "returns quotes from the database without crawling" do
      expect(CrawlerService).not_to receive(:new)
      result = described_class.new(tag).call
      expect(result).to eq(quotes)
    end
  end

  context "when tag is not cached" do
    after { TagCache.destroy_all }

    it "crawls the site and saves to the database" do
      allow_any_instance_of(CrawlerService).to receive(:call).and_return(quotes)
      result = described_class.new(tag).call
      expect(result).to eq(quotes)
      expect(TagCache.where(name: tag).first).not_to be_nil
    end
  end

  context "when tag exists but has no quotes" do
    before { TagCache.destroy_all; TagCache.create!(name: tag, quotes: []) }

    after { TagCache.destroy_all }

    it "crawls the site again" do
      allow_any_instance_of(CrawlerService).to receive(:call).and_return(quotes)
      result = described_class.new(tag).call
      expect(result).to eq(quotes)
    end
  end
end
