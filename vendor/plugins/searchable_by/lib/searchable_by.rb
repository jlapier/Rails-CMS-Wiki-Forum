# Adds a search method to query your ActiveRecord models
#
#  # declare with searchable_by
#  class User < ActiveRecord::Base
#    # enables the "search" method and by default searches 'login' and 'email' columns
#    searchable_by :login, :email
#  end
#
#  # search into associations
#  class User < ActiveRecord::Base
#    has_many :addresses
#    searchable_by :user => [:login, :email], :addresses => [:street, :city]
#  end
#
#  simple search - based on default fields in searchable_by line
#  User.search 'fred'
#  => [#<User>, #<User>]
#
#  # specify which fields to search on with :narrow_fields
#  User.search 'fred', :narrow_fields => [:email, :login, :name]
#  => [#<User>, #<User>, #<User>]
#
#  # use default search fields but pass other options
#  User.search 'fred', :conditions => { :is_admin => true }, :limit => 2
#  => [#<User>, #<User>]
#
#  # use :page option and we'll assume that you want to paginate using will_paginate
#  User.search 'j', :page => 2
#  => [#<User>, #<User>, #<User>, #<User>, #<User>]
#
#  # by default, all search words must be found
#  User.search 'fred john jack susan'
#  => []
#
#  # set :require_all to false if you want to do an "OR" search
#  User.search 'fred john jack susan', :require_all => false
#  => [#<User>, #<User>, #<User>, #<User>, #<User>]
#
#  # use double quotes to identify phrases
#  User.search '"fred flintstone"', :narrow_fields => [:login, :full_name]
#  => [#<User>]
#

module Offtheline
  module SearchableBy
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def searchable_by(*tables_and_columns)
        @search_tables_and_columns = make_hash_from_cols_and_tables(tables_and_columns)
      end

      def search_tables_and_columns
        @search_tables_and_columns
      end

      # in addition to other find options, there is an option to
      # :require_all keywords or phrases (true by default) and an option
      # :narrow_fields to change the fields you want to search from the default specified in searchable_by
      def search(query, options = {})
        cols_with_tables = options[:narrow_fields] ? make_hash_from_cols_and_tables(options[:narrow_fields]) : @search_tables_and_columns
        options[:require_all] = true if options[:require_all].nil?

        with_scope :find => { :conditions => search_conditions(query, options[:require_all], cols_with_tables),
                          :include => cols_with_tables.keys.reject{|k| k == table_name.to_sym } } 	do
          # strip out 'search' specific options
          search_options = options.reject { |k,v| [:require_all, :narrow_fields].include? k.to_sym }
          if options.include?(:page)
            # I think this will help us fail if will_paginate is not installed
            gem 'mislav-will_paginate'
            # take out require_all option when calling paginate
            paginate :all, search_options
          else
            # take out require_all option when calling find
            find :all, search_options
          end
        end
      end

      private

      def make_hash_from_cols_and_tables(tables_and_columns)
        tables_and_columns = [tables_and_columns].flatten
        hash_of_tables_and_columns = { table_name.to_sym => [] }
        tables_and_columns.each do |table_or_column|
          if table_or_column.is_a? Hash
            hash_of_tables_and_columns.merge! table_or_column
          else
            hash_of_tables_and_columns[table_name.to_sym] << table_or_column
          end
        end
        hash_of_tables_and_columns
      end

      def search_conditions(query, require_all, cols_with_tables=nil )
        return nil if query.blank?
        cols_with_tables ||= @search_tables_and_columns

        # pull out "quoted phrases" - this regular expression will find all matches of phrases
        # that start and end with a double-quote
        phrases = query.scan(/\"\w+[^\"]*\w+\"/)
        unless phrases.empty?
          # replace the phrase with an empty string
          phrases.each { |phrase| query.gsub! phrase, '' }
          # take the quotes out of the phrase
          phrases = phrases.map { |ph| ph.gsub("\"", '') }
        end

        # note how we split keywords by commas and spaces, just in case
        words = query.split(",").map(&:split).flatten

        # the uniq takes care of any dupes
        words_and_phrases = (words + phrases).uniq

        binds = {}    # bind symbols
        or_frags = [] # OR fragments
        cnt = 1       # to keep count on the symbols and OR fragments

        # create 'conditions' parts for each word
        for word_or_phrase in words_and_phrases
          # generate our little SQL bites for each field that we want to check for the keyword
          like_frags = cols_with_tables.map { |table,fields|
            [fields].flatten.map { |f| "#{table.to_s.tableize}.#{f} LIKE :word#{cnt}" } }.flatten
          or_frags << "(#{like_frags.join(" OR " )})"
          binds["word#{cnt}".to_sym] = "%#{word_or_phrase.to_s.downcase}%"
          cnt += 1
        end

        # return the OR fragments joined by ANDs (if require_all) or ORs
        # and the named bind variables
        [or_frags.join(require_all ? " AND " : " OR " ), binds]
      end
    end
  end
end