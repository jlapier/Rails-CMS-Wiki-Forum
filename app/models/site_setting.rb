# == Schema Information
# Schema version: 20100216214034
#
# Table name: site_settings
#
#  id                   :integer       not null, primary key
#  setting_name         :string(255)   
#  setting_string_value :string(255)   
#  setting_text_value   :text          
#  setting_number_value :integer       
#  yamled               :boolean       
#  created_at           :datetime      
#  updated_at           :datetime      
# End Schema

class SiteSetting < ActiveRecord::Base
  validates_presence_of :setting_name

  class << self
    def read_setting(name)
      val = Rails.cache.read(name)

      unless val
        setting = find :first, :conditions => { :setting_name => name }
        return nil unless setting

        if setting.setting_number_value
          val = setting.setting_number_value
        elsif !setting.setting_string_value.blank?
          val = setting.setting_string_value
        else
          val = setting.setting_text_value
        end
        if setting.yamled?
          begin
            val = YAML::load(val)
          rescue Exception => e
            val = "Error parsing yaml for setting #{name}: #{e}"
          end
        end
        Rails.cache.write(name, val)
      end
      val
    end

    def write_setting(name, value)
      setting = find :first, :conditions => { :setting_name => name }
      unless setting
        setting = SiteSetting.new :setting_name => name, :yamled => false
      end

      # reset old in case this changed from one type to another
      setting.setting_text_value = nil
      setting.setting_string_value = nil
      setting.setting_number_value = nil
      setting.yamled = false
      
      if value.is_a? Integer
        setting.setting_number_value = value
      elsif value.is_a? String and value.size < 250
        setting.setting_string_value = value
      elsif value.is_a? String
        setting.setting_text_value = value
      else
        yamled_value = value.to_yaml
        setting.yamled = true
        if yamled_value.size < 250
          setting.setting_string_value = yamled_value
        else
          setting.setting_text_value = yamled_value
        end
      end
      if setting.save
        Rails.cache.write(name, value)
      end
    end

    def read_or_write_default_setting(name, default_value)
      val = read_setting(name)
      unless val
        val = default_value
        write_setting name, default_value
      end
      val
    end
  end
end


SiteSetting.partial_updates = false
