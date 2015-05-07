module SampleGithubApp
  class Github

    include HTTParty
    base_uri 'https://api.github.com/'

    attr_accessor :token

    def initialize(auth_token=nil)
      self.token          = auth_token
      self.token        ||= "61eeb64a570f5f63068adf1e77fbb43e47948adc" #token from an already authorized user
      headers             = {"Authorization" => "token #{token}", "User-Agent" => "Specle Sample App"} # pass token and user-agent for higher number of calls

      @options            = {}
      @options[:headers]  = headers
    end

    #check if user exits in github
    def check_user_exists(username)
      resp = self.class.get("/users/#{username}", @options)
      return (resp.code == 200 ? true : false)
    end

    # get all public repos for a username
    def get_public_repos(username, next_url=nil)
      resp   = self.class.get(next_url, @options) if next_url
      resp ||= self.class.get("/users/#{username}/repos", @options)
      return (resp.code == 200 ? resp : false)
    end

    #get user commits in last one year for a particular repo
    def get_last_year_commits(username, repo)
      resp = self.class.get("/repos/#{username}/#{repo}/stats/participation", @options)
      # If the data hasn’t been cached github sends response 202
      if resp.code == 202
        get_last_year_commits(username, repo)
      end
      return (resp.code == 200 ? resp.parsed_response : false)
    end
  end 
end