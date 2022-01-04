
class Blog::Author
  attr_reader :name, :title, :bio, :short_name, :email, :image_url,
              :author, :alumni, :team, :hidden, :spotlight, :noteworthy,
              :website_url, :twitter, :linkedin_url, :github_url, :youtube_url, 
              :facebook_url, :stackoverflow_url, :twitch_url, :blogposts, :url

  # DEFAULT_AVATAR = 'https://avatars.githubusercontent.com/u/2683897'
  DEFAULT_AVATAR = 'https://pbs.twimg.com/profile_images/1410653053578010628/3EZv_tGF_400x400.jpg'

  def initialize(attributes = {})
    @name       = attributes['name']           || 'Vonage Team Member'
    @title      = attributes['title']          || 'Vonage Team Member'
    @bio        = attributes['bio']            || ''
    @short_name = attributes['short_name']     || 'vonage_team_member'
    @email      = attributes['email']          || ''
    @image_url  = attributes['image_url']      || ''
    
    @author     = attributes['author']         || ''
    @alumni     = attributes['alumni']         || false
    @team       = attributes['team']           || false
    @hidden     = attributes['hidden']         || false
    @spotlight  = attributes['spotlight']      || false
    @noteworthy = attributes['noteworthy']     || ''
    
    @website_url  = attributes['website_url']  || ''
    @twitter      = attributes['twitter']      || ''
    @linkedin_url = attributes['linkedin_url'] || ''
    @github_url   = attributes['github_url']   || ''
    @youtube_url  = attributes['youtube_url']  || ''
    @facebook_url = attributes['facebook_url'] || ''
    @twitch_url   = attributes['twitch_url']   || ''
    @stackoverflow_url = attributes['stackoverflow_url'] || ''

    @blogposts = []
    @url       = build_avatar_url
  end

  def build_all_blogposts_from_author(blogposts_json)
    # TODO: How to handle authors with no Json info? (assay-and-roy)
    @blogposts = blogposts_json.select do |b| 
      if b['author'] && b['author']['short_name'].present?
        b['author']['short_name'].downcase == @short_name.downcase
      else
        b['author'] == nil
      end
    end.map { |b| Blog::Blogpost.new b }

    self
  end

  def build_avatar_url
    return DEFAULT_AVATAR unless image_url.present?

    image_url.include?('gravatar') || image_url.include?('https://github.com/') ? 
      image_url : 
        "#{Blog::Blogpost::CLOUDFRONT_BLOG_URL}authors/#{image_url.gsub('/content/images/','')}"    
  end
end
  