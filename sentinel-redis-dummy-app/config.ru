class App
  def self.call(env)
    [200, {'Content-Type' => 'text/html'}, ["Hello Rack."]]
  end
end


run App
require 'sidekiq'

Sidekiq.configure_client do |config|    # and repeat this inside a Sidekiq.configure_server
  config.redis = {
    master_name: 'redis-cluster',
    sentinels: [
      "sentinel://127.0.0.1:16381",
      "sentinel://127.0.0.1:16382",
      "sentinel://127.0.0.1:16383",
    ],
    failover_reconnect_timeout: 20,      # roughly 3-5 seconds longer than the sentinel failover-timeout
  }
end

Sidekiq.configure_server do |config|    # and repeat this inside a Sidekiq.configure_server
  config.redis = {
    master_name: 'redis-cluster',
    sentinels: [
      "redis://127.0.0.1:16381",
      "redis://127.0.0.1:16382",
      "redis://127.0.0.1:16383",
    ],
    failover_reconnect_timeouts: 20,      # roughly 3-5 seconds longer than the sentinel failover-timeout
  }
end

require 'pry'
binding.pry
require 'sidekiq/web'
run Sidekiq::Web
