require 'redis'
require 'timeout'
require 'logger'

class TestClient
  def initialize
    @cluster_name='redis-cluster'
    @sentinels = [
      { host: '127.0.0.1', port: '16380' },
      { host: '127.0.0.1', port: '16381' },
      { host: '127.0.0.1', port: '16382' },
    ]
    @redis = Redis.new(
      :url => "redis://#{@cluster_name}",
      :sentinels => @sentinels,
      :failover_reconnect_timeout => 60,
      :logger => Logger.new(STDOUT),
      # :role => :master
    )
  end

  def reset
    @redis = Redis.new(
      :url => "redis://#{@cluster_name}",
      :sentinels => @sentinels,
      :failover_reconnect_timeout => 60,
      :logger => Logger.new(STDOUT),
      # :role => :master
    )
  end
  
  def test_connection
    input = Random.rand(10_000_000)
    output = nil
    @redis.set("foo#{input}", input)

    output = @redis.get('foo#{input}').to_i
    
    # return "ERROR: Incorrect response #{input} != #{output}" unless input == output
    return "Success (#{input} == #{output}) from #{@redis.id}"
  end
end


test = TestClient.new
while true
  begin
    puts test.test_connection
  # sleep 3
  rescue Redis::TimeoutError
    puts "retrying again.."
    test.reset
  rescue Redis::CannotConnectError 
    puts "retrying again.."
    test.reset
    # puts test.test_connection
  # sleep 3
  end
  sleep 1 
end
