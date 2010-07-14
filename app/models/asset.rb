class Asset < ActiveRecord::Base
  has_attachment :storage => :file_system,
                 :path_prefix => 'public/assets',
                 :max_size => 7.megabytes,
                 :resize_to => '900',
                 :thumbnails => { :large => '480x480', :medium => '230x230', :thumb => '184x184', :square => '75x75!' }
                 
  has_many :assetings, :dependent => :delete_all
  belongs_to :assetable, :polymorphic => true
  
  named_scope :not_thumbnails, :conditions => 'parent_id IS NULL'
  named_scope :images, :conditions => "content_type LIKE 'image%'"
  named_scope :documents, :conditions => "content_type NOT LIKE 'image%'"
                 
  validates_as_attachment
  # validates_presence_of :description, :unless => :is_thumbnail?
  
  attr_accessor :position
  attr_accessible :category, :description, :uploaded_data
  
  def description
    read_attribute('description').blank? ? 'No Description' : super
  end
  
  def category
    read_attribute('category').blank? ? 'No Folder' : super
  end
  
  def is_thumbnail?
    !parent_id.nil?
  end
  
  def file_type
    self.content_type.split("/")[1]
  end
  
  def is_image?
    content_type =~ /image/
  end
  
  def self.grouped_by_content_type
    self.not_thumbnails.group_by(&:content_type).sort
  end
  
  def self.grouped_by_category
    self.not_thumbnails.group_by(&:category).sort
  end
  
  def self.categories
    self.find(:all, :group => "category", :select => "category", :order => 'category')
  end
  
  def sizes
    sizes = []
    if is_image? and not is_thumbnail?
      sizes << [ 'fullsize', public_filename ]
      attachment_options[:thumbnails].each_key do |key|
        sizes << [key.to_s, public_filename(key)]
      end
    end
    sizes
  end
  
  def to_json(options = {})
    methods = [:public_filename]
    methods << :sizes if is_image?
    options.reverse_merge! :methods => methods
    super options
  end


end
