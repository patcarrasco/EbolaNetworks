require 'pry'
require './like'
require './user'
require './tweet'


coffee_dad = User.new("CoffeeFather")
bird_girl = User.new("BirdLady")
cakelover = User.new("CakeLuv3r")

coffee_dad.post_tweet("COFFEE YUM")
bird_girl.post_tweet("Darkness")
cakelover.post_tweet("great lemon cake")
tweet = Tweet.new("ilove chiffon", cakelover)
tweet1 = Tweet.new("caef", coffee_dad)
tweet2 = Tweet.new("birds", bird_girl)
coffee_dad.like_tweet(tweet)
bird_girl.like_tweet(tweet)
bird_girl.like_tweet(tweet2)
cakelover.like_tweet(tweet1)


binding.pry

puts "Done"
