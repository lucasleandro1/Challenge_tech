user = User.find_or_initialize_by(email: "admin@dimensa.com")
unless user.persisted?
  user.password = "senha123"
  user.save!
  puts "Usuário criado: admin@dimensa.com / senha123"
else
  puts "Usuário já existe: admin@dimensa.com"
end

tag_cache = TagCache.find_or_initialize_by(name: "inspirational")
unless tag_cache.persisted?
  tag_cache.quotes = [
    {
      "quote" => "The only way to do great work is to love what you do.",
      "author" => "Steve Jobs",
      "author_about" => "http://quotes.toscrape.com/author/Steve-Jobs",
      "tags" => [ "inspirational", "work" ]
    },
    {
      "quote" => "In the middle of every difficulty lies opportunity.",
      "author" => "Albert Einstein",
      "author_about" => "http://quotes.toscrape.com/author/Albert-Einstein",
      "tags" => [ "inspirational" ]
    },
    {
      "quote" => "It does not matter how slowly you go as long as you do not stop.",
      "author" => "Confucius",
      "author_about" => "http://quotes.toscrape.com/author/Confucius",
      "tags" => [ "inspirational", "perseverance" ]
    }
  ]
  tag_cache.save!
  puts "TagCache criado: inspirational (#{tag_cache.quotes.size} quotes)"
else
  puts "TagCache já existe: inspirational"
end
