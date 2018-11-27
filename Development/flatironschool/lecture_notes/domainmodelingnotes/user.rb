class User

  @@all = []

  def self.all
    @@all
  end

  def initialize(username)
    @username = username
    User.all << self
  end

  attr_reader :username

  def tweets
    Tweet.all.select {|tweet| tweet.user == self}
  end

  def post_tweet(message)
    Tweet.new(message, self)
  end

  def like_tweet(tweet)
    Like.new(tweet, self)
  end

  def liked_tweets
    Like.all.select{|like| like.user == self}.collect{|like| like.tweet}
  end

  def number_of_likes
    liked_tweets.count
  end

  def liked_tweets_content
    liked_tweets.collect {|likes| likes.tweet.content}
  end

end
