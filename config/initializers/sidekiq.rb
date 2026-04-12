Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

  config.on(:startup) do
    schedule = [
      {
        "name"  => "refresh_quotes_job",
        "cron"  => "0 0,12 * * *",
        "class" => "RefreshQuotesJob"
      }
    ]

    Sidekiq::Cron::Job.load_from_array!(schedule)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end
