# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

class Person < ActiveRecord::Base
  belongs_to :person_entity, :foreign_key => 'entity_id'

  belongs_to :birth_gender, :class_name => 'ExternalCode'
  belongs_to :ethnicity, :class_name => 'ExternalCode'
  belongs_to :primary_language, :class_name => 'ExternalCode'

  validates_presence_of :last_name
  validates_date :birth_date, :allow_nil => true
  validates_date :date_of_death, :allow_nil => true
  validates_length_of :last_name, :maximum => 25, :allow_blank => true
  validates_length_of :first_name, :maximum => 25, :allow_blank => true
  validates_length_of :middle_name, :maximum => 25, :allow_blank => true

  before_save :generate_soundex_codes

  named_scope :clinicians,
     :conditions => "person_type = 'clinician'",
     :order => "last_name, first_name"

  named_scope :active_clinicians, 
     :joins => "INNER JOIN entities on people.entity_id = entities.id",
     :conditions => "person_type = 'clinician' AND entities.deleted_at IS NULL",
     :order => "last_name, first_name"

  # Debt? Just getting this done fast after dives on options took a long time.
  # Should method this be in entity.rb? Is there a better way to handle custom
  # SQL? What about this?
  # http://www.edwardthomson.com/blog/2007/02/complex_sql_queries_with_rails.html
  def self.find_by_ts(*args)
    options = args.extract_options!
    where_clause = ""
    order_by_clause = ""
    fulltext_terms = []
    issue_query = false
    
    # Debt: The UI shows the user a format to use. Something a bit more robust
    # could be in place.    
    if !options[:birth_date].blank?
      american_date = '%m/%d/%Y'
      date = Date.strptime(options[:birth_date], american_date).to_s
      issue_query = true
      where_clause += "birth_date = '#{date}'"
      order_by_clause += "last_name, first_name ASC;" 
    end
    
    # Some more debt here. The sql_term building is duplicated in Event. Where
    # do you factor out code common to models? Also, it may be that we don't need
    # two different search avenues (CMR and People).
    if !options[:fulltext_terms].blank?
      
      issue_query = true
      soundex_codes = []
      raw_terms = options[:fulltext_terms].strip.split(/\s+/)
      
      raw_terms.each do |word|
        soundex_codes << word.to_soundex.downcase unless word.to_soundex.nil?
        fulltext_terms << sanitize_sql_for_conditions(["%s", word]).sub(",", "").downcase
      end
      
      fulltext_terms << soundex_codes unless soundex_codes.empty?
      sql_terms = fulltext_terms.join(" | ")
      
      where_clause += " AND " if !where_clause.empty?
      where_clause += "vector @@ to_tsquery('#{Utilities::sanitize_for_tsquery(sql_terms)}')"
      order_by_clause = " ts_rank(vector, '#{sql_terms}') DESC, last_name, first_name ASC;"
    end
    
    query = "SELECT people.entity_id, first_name, middle_name, last_name, birth_date, c.code_description as gender, co.code_description as county
                  FROM (SELECT DISTINCT ON(entity_id) * FROM people ORDER BY entity_id, created_at DESC) people
                    LEFT OUTER JOIN external_codes c on c.id = people.birth_gender_id
                    LEFT OUTER JOIN addresses a on a.entity_id = people.entity_id
                    LEFT OUTER JOIN external_codes co on co.id = a.county_id
                  WHERE #{where_clause} ORDER BY #{order_by_clause}"
    
    find_by_sql(query) if issue_query
  end

  def full_name
    "#{self.first_name} #{self.last_name}".strip
  end

  def last_comma_first
    ("#{self.last_name}"  << (self.first_name.blank? ? "" : ", #{self.first_name}")).strip
  end

  def primary_phone
    self.person_entity.primary_phone
  end

  def age
    (Date.today - self.birth_date.to_date).to_i / 365 unless self.birth_date.blank?
  end

  def birth_gender_description
    birth_gender.code_description unless birth_gender.blank?
  end

  def ethnicity_description
    ethnicity.code_description unless ethnicity.blank?
  end

  def primary_language_description
    primary_language.code_description unless primary_language.blank?
  end

  # Builds a presentable description of the person's race.
  def race_description
    unless person_entity.blank? || person_entity.races.empty?
      races = person_entity.races.collect {|race| race.code_description}
      description = races[0...-1] * ', '
      description += ' and ' if races.size > 1
      return description + races[-1]
    end  
  end

  class << self
    # Defaults to not showing deleted people. Override by providing the option:
    #   :show_deleted => true
    def find_all_for_filtered_view(options = {})
      where_clause = "1=1 "
      joins = ""

      if options[:use_starts_with_search]
        if !options[:last_name].blank?
          where_clause << " AND last_name ILIKE " + sanitize_sql_for_conditions(["'%s%%'", options[:last_name].strip]).untaint
        end

        if !options[:first_name].blank?
          where_clause << " AND first_name ILIKE " + sanitize_sql_for_conditions(["'%s%%'", options[:first_name].strip]).untaint
        end

        if !options[:middle_name].blank?
          where_clause << " AND middle_name ILIKE " + sanitize_sql_for_conditions(["'%s%%'", options[:middle_name].strip]).untaint
        end
      else
        soundex_codes = []
        fulltext_terms = []
        raw_terms = []
        raw_terms << options[:first_name].strip.split(/\s+/) unless options[:first_name].nil?
        raw_terms << options[:last_name].strip.split(/\s+/) unless options[:last_name].nil?
        raw_terms = raw_terms.flatten

        raw_terms.each do |word|
          soundex_codes << word.to_soundex.downcase unless word.to_soundex.nil?
          fulltext_terms << word.sub(",", "").downcase
        end

        if !soundex_codes.empty?
          fulltext_terms << soundex_codes unless soundex_codes.empty?
          sql_terms = fulltext_terms.join(" | ")
          sql_terms = sanitize_sql_for_conditions(["'%s'", sql_terms]).untaint

          where_clause << " AND vector @@ to_tsquery(#{sql_terms})"
          order_by_clause = " ts_rank(vector, #{sql_terms}) DESC, last_name, first_name ASC"
        end
      end

      order_by_clause = " last_name, first_name ASC" if order_by_clause.blank?

      if !options[:birth_date].blank?
        where_clause << " AND ( birth_date IS NULL OR birth_date = " + sanitize_sql_for_conditions(["'%s'", options[:birth_date]]).untaint + " )"
      end

      unless options[:show_deleted]
        joins = "INNER JOIN entities on people.entity_id = entities.id"
        where_clause << " AND entities.deleted_at IS NULL"
      end

      select = <<-SQL
        SELECT * FROM people
      SQL
      select << "#{joins}\n" unless joins.empty?
      select << "WHERE (#{where_clause})\n" unless where_clause.blank?
      select << "ORDER BY #{order_by_clause}"

      count_select = <<-SQL
        SELECT COUNT(*) FROM people
      SQL
      count_select << "#{joins}\n" unless joins.empty?
      count_select << "WHERE (#{where_clause})\n" unless where_clause.blank?

      row_count = Person.count_by_sql(count_select)

      find_options = {
        :page          => options[:page],
        :total_entries => row_count
      }
      find_options[:per_page] = options[:per_page] if options[:per_page].to_i > 0

      Person.paginate_by_sql(select, find_options)

    rescue Exception => ex
      logger.error ex
      raise ex
    end

  end

  protected
  def validate
    if !date_of_death.blank? && !birth_date.blank?
      errors.add(:date_of_death, "cannot precede birth date") if date_of_death.to_date < birth_date.to_date
    end
  end

  # Soundex codes are generated at save time.
  def generate_soundex_codes
    if !first_name.blank?
      self.first_name_soundex = first_name.to_soundex
    end

    self.last_name_soundex = last_name.to_soundex
  end
  
end
