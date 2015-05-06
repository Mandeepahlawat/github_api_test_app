module ApplicationHelper
	def loader
    content_tag :div, "Loading&#8230;", class: 'loading hidden'
  end
end
