# User Group
#
#
#
# == Schema Information
# Schema version: 20100125191432
#
# Table name: user_groups
#
#  id      :integer       not null, primary key
#  name    :string(255)   
#  special :text(255)     
# End Schema

class UserGroup < ActiveRecord::Base
  SPECIAL_ACCESS = [ 'Wiki Reader', 'Wiki Editor', 'Forum Poster', 'Forum Moderator' ]

  # stored as an Array - list of indexes of SPECIAL_ACCESS
  serialize :special, Hash

  has_and_belongs_to_many :users

  before_save :strip_none_from_special

  class << self
    def find_by_name(name)
      @groups ||= {}
      @groups[name] ||= find( :first, :conditions => { :name => name })
    end

    def find_or_create_by_name(name)
      find_by_name(name) || create(:name => name)
    end
  end

  def forums
    self.special ||= {}
    self.special[:forums] ||= {}
    special[:forums]
  end

  def wikis
    self.special ||= {}
    self.special[:wikis] ||= {}
    special[:wikis]
  end

  def forum_access=(access_hash)
    self.special ||= {}
    self.special[:forums] = access_hash
  end

  def wiki_access=(access_hash)
    self.special ||= {}
    self.special[:wikis] = access_hash
  end
  
  def grants_access_to_forum?(forum_or_forum_id)
    forum_id = forum_or_forum_id.is_a?(Forum) ? forum_or_forum_id.id : forum_or_forum_id
    forums[forum_id.to_s]
  end

  def grants_access_to_wiki?(wiki_or_wiki_id)
    wiki_id = wiki_or_wiki_id.is_a?(Wiki) ? wiki_or_wiki_id.id : wiki_or_wiki_id
    wikis[wiki_id.to_s]
  end

  # returns something human readable, like:
  # Forum: Some Forum 1 (Read), Forum: Some Forum 2 (Write), Wiki: Some Wiki 1 (Read), Wiki: Some Wiki 2 (Write)
  def access_string
    forum_strings = forums.map { |f_id, f_access| "Forum: #{Forum.find(f_id).name} (#{f_access.titleize})" }
    wiki_strings = wikis.map { |w_id, w_access| "Wiki: #{Wiki.find(w_id).name} (#{w_access.titleize})" }
    [forum_strings + wiki_strings].join(', ')
  end
  
  def drop_users(drop_user_ids)
    drop_user_ids = [*drop_user_ids].compact.map(&:to_i)
    self.user_ids = user_ids - drop_user_ids
    self.save
  end

  private
  def strip_none_from_special
    # make sure the hashes are set up so we don't error out
    forums
    wikis

    self.special[:forums].reject! { |f_id, access| access == "none" }
    self.special[:wikis].reject!  { |w_id, access| access == "none" }
  end
end
