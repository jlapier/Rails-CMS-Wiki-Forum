# t.string   "name"
# t.text     "description"
# t.string   "filepath"
# t.integer  "event_id"
# t.datetime "created_at"
# t.datetime "updated_at"

class FileAttachment < ActiveRecord::Base
  set_table_name "file_share_file_attachments"
  
  REL_ROOT_DIR = File.join 'public', 'files'
  ABS_ROOT_DIR = File.join Rails.root, REL_ROOT_DIR
  
  #FOLDER = 'files'
  #FOLDER_ROOT = File.join(Rails.root.to_s, 'public')
  #FOLDER_PATH = File.join(FOLDER_ROOT, FOLDER)
  #TRASH_FOLDER = File.join(FOLDER_PATH, 'trash')
  
  validates_presence_of :name, :filepath
  
  belongs_to :attachable, :polymorphic => true
  
  before_validation :autofill_blank_name, :on => :create
  before_validation :build_filepath, :on => :create
  after_save :save_to_folder_path, :if => Proc.new{|file| file.uploaded_file.present?}
  before_save :normalize_attachable_fields
  before_destroy :move_file_to_trash_folder!

  attr_accessor :uploaded_file
  
  scope :orphans, where('attachable_id IS NULL')
  scope :attached, where('attachable_id IS NOT NULL')
  
  private
    def attachable_folder
      if attachable_type.blank? or attachable_id.blank?
        "general"
      else
        File.join attachable_type.underscore.downcase, attachable_id.to_s
      end
    end
    def normalize_attachable_fields
      if attachable_type.blank? || attachable_id.blank?
        self.attachable_type = nil
        self.attachable_id = nil
      end
    end
    def move_file_to_trash_folder!
      trash_folder = File.join ABS_ROOT_DIR, attachable_folder, 'trash'
      ensure_folder_path_exists(trash_folder)
      trash_filename = generate_unique_filename(trash_folder)
      
      FileUtils.mv(full_path, File.join(trash_folder, trash_filename))
      
      unless File.exists?(File.join(trash_folder, trash_filename))
        raise Errno::ENOENT("The file at #{filepath} should be in the trash but it is not.")
      end
      logger.info("Moved File Attachment to Trash: #{File.join(trash_folder, trash_filename)}")
    end
    def save_to_folder_path
      ensure_folder_path_exists
      File.open(full_path, "wb") { |f| f.write(uploaded_file.read) }
      return true if file_saved?
      errors.add(:base, "The file could not be saved. Please try again or contact someone and make a note of how many files, what kind, etc.")
      false
    end
    def generate_unique_filename(dest_path=nil)
      dest_path ||= File.join ABS_ROOT_DIR, attachable_folder
      base_filename = File.basename(uploaded_file && uploaded_file.original_filename || filepath)
      new_filename = base_filename
      path = File.join dest_path, new_filename
      count = 0
      until !File.exists? path
        count += 1
        new_filename = base_filename.gsub File.extname(base_filename), "-#{count}#{File.extname(base_filename)}"
        path = File.join dest_path, new_filename
        raise "Unable to generate a unique filename for #{base_filename}; tried #{count} times." if count > 99
      end
      new_filename
    end
    def ensure_folder_path_exists(dest_path=nil)
      dest_path ||= File.join ABS_ROOT_DIR, attachable_folder
      FileUtils.mkdir_p dest_path
    end
    def build_filepath
      self.filepath = File.join REL_ROOT_DIR, attachable_folder, generate_unique_filename
    end
    def autofill_blank_name
      if name.blank?
        self.name = self.uploaded_file.original_filename
      end
    end
  protected
  public
    def full_path
      # for backward compat; previous releases stored filepath relative to 'public'.
      # ie 'public' was not included in the filepath
      if filepath.include? REL_ROOT_DIR
        File.join Rails.root, filepath
      else
        File.join Rails.root, 'public', filepath
      end
    end
    def file_saved?
      return true if File.exists?(full_path) && File.basename(full_path) != REL_ROOT_DIR.split("/").last
      return false
    end
    def file_container
      return nil unless attachable_type.present? && attachable_id.present?
      "#{attachable_type}_#{attachable_id}"
    end
    def file_container=(container)
      p = container.split("_")
      self.attachable_type = p[0].blank? ? nil : p[0]
      self.attachable_id = p[1].blank? ? nil : p[1]
    end
    
    # update fs & db filepaths with updated values (eg after dev changes)
    def update_filepath
      old_path = full_path.dup
      build_filepath
      FileUtils.mv(old_path, full_path)
      unless file_saved?
        msg = "Error updating filepath for #{name}"
        logger.error(msg)
        errors.add(:base, msg)
        false
      else
        self.save
      end
    end
end
