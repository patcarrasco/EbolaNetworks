class Tweet
  @@all = []

  def self.all
    @@all
  end

  attr_reader :user, :content, :username

  def initialize(content, user) # user refers to a SPECIFIC USER INSTANCE
    @content = content
    @user = user
    @username = user.username
    Tweet.all << self
  end

end
