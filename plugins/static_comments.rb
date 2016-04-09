# Store and render comments as a static part of a Jekyll site
#
# See README for detailed documentation on this plugin.
#
# Homepage: https://github.com/taringamberini/octopress-static-comments
#
# Inspired by:
#
# * Matt Palmer Jekyll Static Comments plugin available at
#   http://theshed.hezmatt.org/jekyll-static-comments
# * Kaimi Octopress Static Comments plugin available at
#   https://github.com/kaimi/octopress-static-comments
#
#  Copyright (C) 2016 Tarin Gamberini <www.taringamberini.com>
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 3, as
#  published by the Free Software Foundation.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, see <http://www.gnu.org/licences/>

class Jekyll::Post
	alias :to_liquid_without_comments :to_liquid
	
	def to_liquid(*args)
		data = to_liquid_without_comments(*args)
		data['static_comments'] = StaticComments::find_for_post(self)
		data['static_comments_count'] = data['static_comments'].length
		data
	end
end

module StaticComments
	# Find all the comments for a post
	def self.find_for_post(post)
		@comments ||= read_comments(post.site.source)
		@comments[post.id]
	end
	
	# Read all the comments files in the site, and return them as a hash of
	# arrays containing the comments, where the key to the array is the value
	# of the 'post_id' field in the YAML data in the comments files.
	#
	# If a comment YAML file hasn't a 'comment_id' field then a suitable
	# 'comment_id' is written into it. The 'comment_id' value is computed as
	# the ordinal position of the comment among all comment YAML files sorted
	# by the mandatory 'date' YAML field. In this way each comment has its own
	# 'comment_id' which can be used as comment permalink, still leaving the
	# freedom to put the comment YAML file everywhere under '_comments'
	# directory.
	def self.read_comments(source)
		comments = Hash.new() { |h, k| h[k] = Array.new }
        sorted_comments, max_comment_id = sort_and_max(source)
		
        sorted_comments.keys.each do |comment|
			yaml_data = YAML::load_file(comment)
            max_comment_id = write_new_comment_id(comment, yaml_data, max_comment_id)
            post_id = yaml_data.delete('post_id')
			comments[post_id] << yaml_data
		end
		
		comments
	end

	# Read all comments in the site and return the following two object:
	# 
	# 1. sorted_comments - Comments sorted by their 'date' YAML field. Comments
	#    are returned as a hash of arrays containing the dates, where the
	#    key to the array is the comment YAML file pathname.
	#
	# 2. max_comment_id - The max 'comment_id' among 'comment_id' YAML fields
	#    of the comment files. If none of the comment YAML files have a
    #    'comment_id' YAML field then 0 is returned.
	def self.sort_and_max(source)
        sorted_comments = Hash.new() { |date, comment| date[comment] = Array.new }

        max_comment_id = 0
		Dir["#{source}/**/_comments/**/*"].each do |comment|
			next unless File.file?(comment) and File.readable?(comment)
			yaml_data = YAML::load_file(comment)
            sorted_comments[comment] << yaml_data['date']
            comment_id = yaml_data['comment_id']
            unless comment_id.nil?
				max_comment_id = [max_comment_id, comment_id.to_i].max 
            end
        end
        sorted_comments = Hash[sorted_comments.sort_by{ |comment, date| date }]
        
		return sorted_comments, max_comment_id
    end

	# Return the same max_comment_id passed as input arguments if a
	#  'comment_id' field yet exists in the comment YAML file.
	#
	# Return max_commend_id + 1 if a 'comment_id' field doesn't exist
	# in the comment YAML file. In such case:
	#
	# * set the 'comment_id' YAML field to max_commend_id + 1
	# * remove a possible 'submit' YAML field
	# * write YAML data into the comment file
	def self.write_new_comment_id(comment, yaml_data, max_comment_id)
        comment_id = yaml_data['comment_id']
        if comment_id.nil?
            max_comment_id = max_comment_id + 1
            yaml_data['comment_id'] = max_comment_id.to_s
            yaml_data.delete('submit')
            File.open(comment,'w') do |h| 
				h.write yaml_data.to_yaml
            end
        end

        max_comment_id
    end

end
