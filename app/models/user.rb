class User < ActiveRecord::Base

	validates :username, uniqueness: true

	default_scope { order(total_commits_last_year: :desc) }

	#get public repos for a username
	def self.get_public_repos(git, username, public_repos=nil, next_url=nil)
		public_repos  	||= []
		resp 							= git.get_public_repos(username, next_url)
		if resp
			resp.each{|repo| public_repos <<  repo["name"]}  #add all repo names in public repo array
			if resp.headers["link"] #if pagination link present
				next_url 			= resp.headers["link"].split("\;").first.gsub!(/[<>]/,"")
				get_public_repos(git, username, public_repos, next_url) if (next_url.split("?page=")[1] != "1") #call method only if pagination link not equal to 1
			end
		end
		return public_repos
	end

	def self.fetch_all_public_repos(git, username)
		get_public_repos(git, username)
	end

	#get activity for a particular repo and username
	def self.get_activity_for_repo(git, repo, username)
		resp						= git.get_last_year_commits(username, repo)
		resp ? resp["owner"].inject(:+) : 0
	end

	#get last one year commits for all public repos
	def self.get_last_one_year_commits(git,username)
		public_repos 	= fetch_all_public_repos(git, username)
		if public_repos.present?
			total_commits = []
			public_repos.each do |repo|
				commits = get_activity_for_repo(git, repo, username)
				total_commits << commits
			end
			total_commits.inject(:+)
		else
			false
		end
	end

	#initialize github class
	def self.initialize_github
		SampleGithubApp::Github.new
	end

	#check if github user exits and if exists then create a user with total commits
	def self.check_user_and_get_activity(username)
		git 						= initialize_github
		if git.check_user_exists(username)
			total_commits = get_last_one_year_commits(git, username)
			user 					= User.find_or_initialize_by(username: username)
			user.total_commits_last_year = total_commits if total_commits
			user.save
		else
			false
		end
	end
end
