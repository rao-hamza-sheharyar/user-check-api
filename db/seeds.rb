redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
key = ENV.fetch("COUNTRY_WHITELIST_KEY", "country_whitelist")
redis.del(key)
redis.sadd(key, %w[US GB CA DE FR AU])
puts "Seeded #{redis.scard(key)} countries into '#{key}'"