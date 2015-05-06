class User < ActiveRecord::Base
	validates :username, uniqueness: true

	default_scope { order(total_commits_last_year: :desc) }

	#get public repos for a username
	def self.get_public_repos(git, username)
		resp 					= git.get_public_repos(username)
		resp ? resp.collect{|repo| repo["name"]}  : false
	end

	#get activity for a particular repo and username
	def self.get_activity_for_repo(git, repo, username)
		resp 					= git.get_last_year_activity(username, repo)
		resp ? resp.collect{|c| c["total"]}.inject(:+) : 0
	end

	#get last one year commits for all public repos
	def self.get_last_one_year_commits(git,username)
		public_repos 	= get_public_repos(git, username)
		if public_repos.present?
			total_commits = []
			public_repos.each do |repo|
				commits = get_activity_for_repo(git, repo, username)
				debugger
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
			debugger
			user 					= User.find_or_initialize_by(username: username)
			user.total_commits_last_year = total_commits
			user.save
		else
			false
		end
	end
end
