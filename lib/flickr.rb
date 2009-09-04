# = Flickr
#   An insanely easy interface to the Flickr photo-sharing service. By Scott Raymond.
#   Modified by Steve England www.wearebeef.co.uk

# Now using ObjectiveFlickr gem as it makes auth easy
# gem 'objectiveflickr'
require 'objectiveflickr'

class Flickr
  
  def self.connect(api_key, secret, auth_token = nil)
    API.connect(api_key, secret, auth_token)
    self
  end

  class Error < StandardError ; end

  # Essentially a standard RuntimeError that can include the response as an
  # REXML object reference.
  class APIError < Error
    attr_reader :response
 
    # Creates a new exception.
    def initialize(response)
      super
      @response = response
    end
 
    # The error string returned by the API call.
    def to_s
      response['message']
    end
  end

  # Flickr client class. Requires an API key, and optionally takes an email and password for authentication
  class API
    class << self

      # Replace this API key with your own (see http://www.flickr.com/services/api/misc.api_keys.html)
      def connect(api_key, secret, auth_token = nil)
        @api_key = api_key
        @auth_token = auth_token
        @fi = FlickrInvocation.new(api_key,secret)
        self
      end
      
      def fi
        raise Error.new('API not connected') if @fi.nil?
        @fi
      end
    
      def login_url(permission='read')
        fi.login_url(permission)
      end
    
      def unauthorised?
        params = { :api_key => @api_key, :auth_token => @auth_token }
        logger.debug params
        data = fi.call('flickr.auth.checkToken',params).data
        logger.debug data
        return data['message'] if data['stat'] != 'ok'
        false
      end
    
      def authorise(frob)
        @auth_token = request('flickr.auth.getToken', { :api_key => @api_key, :frob => frob } )['auth']['token']['_content']
      end

      # Implements flickr.urls.lookupGroup and flickr.urls.lookupUser
      def find_by_url(url)
        response = urls_lookupUser('url'=>url) rescue urls_lookupGroup('url'=>url) rescue nil
        (response['user']) ? User.new(response['user']['id']) : Group.new(response['group']['id']) unless response.nil?
      end

      # Implements flickr.photos.getRecent and flickr.photos.search, returns PhotoList object so
      # that page_count, total etc. are avaiable for pagination.
      def photos(params = {})
        photos = (params.empty?) ? photos_getRecent['photos'] : photos_search(params)['photos']
        PhotoList.new(photos, self)
      end

      # Implements flickr.people.getOnlineList, flickr.people.findByEmail, and flickr.people.findByUsername
      def users(lookup=nil)
        if(lookup)
          user = people_findByEmail('find_email'=>lookup)['user'] rescue people_findByUsername('username'=>lookup)['user']
          return User.find(user['nsid'])
        else
          return people_getOnlineList['online']['user'].collect { |person| User.new(person['nsid']) }
        end
      end

      # Implements flickr.groups.getActiveList
      def groups
        groups_getActiveList['activegroups']['group'].collect { |group| Group.new(group['nsid']) }
      end

      # Implements flickr.tags.getRelated
      def related_tags(tag)
        tags_getRelated('tag_id'=>tag)['tags']['tag']
      end

      # Implements flickr.photos.licenses.getInfo
      def licenses
        photos_licenses_getInfo['licenses']['license']
      end

      # Todo:
      # logged_in?
      # if logged in:
      # flickr.blogs.getList
      # flickr.favorites.add
      # flickr.favorites.remove
      # flickr.groups.browse
      # flickr.photos.getCounts
      # flickr.photos.getNotInSet
      # flickr.photos.getUntagged
      # flickr.photosets.create
      # flickr.photosets.orderSets
      # flickr.tags.getListUserPopular
      # flickr.test.login
      # uploading

      private

      def logger
        RAILS_DEFAULT_LOGGER
      end
    
      # Takes a Flickr API method name and set of parameters
      def request(method, params = {}, auth = true)
        params[:auth] = auth
        params[:auth_token] = @auth_token unless @auth_token.nil?
        logger.debug params.inspect
      
      
        data = fi.call(method,params).data
        logger.debug data.inspect
        raise APIError.new(data) if data['stat'] != 'ok' 
        data
      end

      # Implements everything else.
      # Any method not defined explicitly will be passed on to the Flickr API,
      # and return an XmlSimple document. For example, Flickr#test_echo is not defined,
      # so it will pass the call to the flickr.test.echo method.
      # e.g., Flickr#test_echo['stat'] should == 'ok'
      def method_missing(method_id, *params)
        request('flickr.' + method_id.id2name.gsub(/_/, '.'), params[0])
      end
    
    end

  end

  class ApiObject
    
    protected
    
    def initialize(hash)
      hash.each do |key, value|
        instance_variable_set '@' + key, value
      end
    end

    def self.find(*args)
      case args.first
      when :first then find_initial(args[1])
      when :all  then find_every(args[1])
      else find_by_id(args)
      end 
    end
    
  end

  class Person < ApiObject

    attr_reader :nsid, :username, :name, :location, :count, :firstdate, :firstdatetaken
    
    def self.find_by_id(id)
      self.new(API.people_getInfo('user_id'=>id)['person'])
    end

    def self.find_by_email(email)
      id = API.people_findByEmail('find_email'=>email)['user']['nsid']
      find(id)
    end

    # Implements flickr.people.getPublicGroups
    def groups
      API.people_getPublicGroups('user_id'=>@nsid)['groups']['group'].collect { |group| Group.new(group['nsid']) }
    end

    def photos(params = {})
      @photolist ||= API.photos(params.merge('user_id'=>@nsid, 'sort'=>'date-taken-desc'))
    end

    # Implements flickr.photosets.getList
    def photosets
      if @photosets.nil?
        photosets = API.photosets_getList('user_id'=>@nsid)['photosets']
        if photosets.empty?
          @photosets = []
        else
          @photosets = photosets['photoset'].collect { |photoset| Photoset.new(photoset) }
        end
      else
        @photosets
      end
    end

    # Implements flickr.contacts.getPublicList and flickr.contacts.getList
    def contacts
      API.contacts_getPublicList('user_id'=>@nsid)['contacts']['contact'].collect { |contact| User.new(contact['nsid']) }
    end

    # Implements flickr.favorites.getPublicList and flickr.favorites.getList
    def favorites
      API.favorites_getPublicList('user_id'=>@nsid)['photos']['photo'].collect { |photo| Photo.new(photo) }
      #or
    end

    # Implements flickr.tags.getListUser
    def tags
      API.tags_getListUser('user_id'=>@nsid)['who']['tags']['tag'].collect { |tag| tag }
    end

    # Implements flickr.photos.getContactsPublicPhotos and flickr.photos.getContactsPhotos
    def contactsPhotos
      API.photos_getContactsPublicPhotos('user_id'=>@nsid)['photos']['photo'].collect { |photo| Photo.new(photo) }
      # or
      #API.photos_getContactsPhotos['photos']['photo'].collect { |photo| Photo.new(photo['id']) }
    end

    def to_s
      @name
    end

  end

  class Photoset < ApiObject
    attr_reader :id, :title, :description
    
    def find_by_id(id)
      self.new(photosets_getInfo('photoset_id'=>id)['photoset'])
    end

    def total
      @photos
    end

    def photos
      photo = API.photosets_getPhotos('photoset_id'=>id)['photoset']['photo']
      return [] if photo.nil?
      return [Photo.new(photo, self)] if photo.is_a? Hash
      photo.collect { |photo| Photo.new(photo) }
    end
  end

  class Photo < ApiObject

    attr_reader :id, :title, :owner_id, :server, :isfavourite, :license, :rotation, :description, :notes
    attr_writer :owner
    
    def self.find_by_id(id)
      self.new(API.photos_getInfo('photo_id'=>id)['photo'])
    end
    
    # Implements flickr.photos.getRecent and flickr.photos.search, returns PhotoList object so
    # that page_count, total etc. are avaiable for pagination.
    def self.find_every(params = {})
      photos = (params.empty?) ? API.photos_getRecent['photos'] : API.photos_search(params)['photos']
      PhotoList.new(photos)
    end
    
    def self.find_initial(params = {})
      params[:per_page] = 1
      find_every(params = {})
    end

    # Returns the URL for the photo page (default or any specified size)
    def url(size='Medium')
      if size=='Medium'
        "http://flickr.com/photos/#{owner.username}/#{@id}"
      else
        sizes(size)['url']
      end
    end

    # Returns the URL for the image (default or any specified size)
    def source(size=nil)
      url = "http://static.flickr.com/#{@server}/#{@id}_#{@secret}"
      url << "_#{size}" unless size.nil?
      url + ".jpg"
    end

    # Returns the photo file data itself, in any specified size. Example: File.open(photo.title, 'w') { |f| f.puts photo.file }
    def file(size=nil)
      Net::HTTP.get_response(URI.parse(source(size))).body
    end

    # Unique filename for the image, based on the Flickr NSID
    def filename
      "#{@id}.jpg"
    end

    # Implements flickr.photos.getContext
    def context
      context = API.photos_getContext('photo_id'=>@id)
      @previousPhoto = Photo.new(context['prevphoto']['id'])
      @nextPhoto = Photo.new(context['nextphoto']['id'])
      return [@previousPhoto, @nextPhoto]
    end

    # Implements flickr.photos.getExif
    def exif
      API.photos_getExif('photo_id'=>@id)['photo']
    end

    # Implements flickr.photos.getPerms
    def permissions
      API.photos_getPerms('photo_id'=>@id)['perms']
    end

    # Implements flickr.photos.getSizes
    def sizes(size=nil)
      sizes = API.photos_getSizes('photo_id'=>@id)['sizes']['size']
      sizes = sizes.find{|asize| asize['label']==size} if size
      return sizes
    end

    # flickr.tags.getListPhoto
    def tags
      API.tags_getListPhoto('photo_id'=>@id)['photo']['tags']
    end

    # Implements flickr.blogs.postPhoto
    def postToBlog(blog_id, title='', description='')
      API.blogs_postPhoto('photo_id'=>@id, 'title'=>title, 'description'=>description)
    end

    # Converts the Photo to a string by returning its title
    def to_s
      @title
    end

  end

  # Todo:
  # flickr.groups.pools.add
  # flickr.groups.pools.getContext
  # flickr.groups.pools.getGroups
  # flickr.groups.pools.getPhotos
  # flickr.groups.pools.remove
  class Group < ApiObject
    attr_reader :id, :client, :name, :members, :online, :privacy, :chatid, :chatcount, :url
    
    def self.find_by_id(id)
      self.new(API.groups_getInfo('user_id'=>id)['person'])
    end
    
    def self.photos(id, params = {})
      params['group_id'] = id
      PhotoList.new(API.groups_pools_getPhotos(params)['photos'])
    end
    
    
  end
  
  # Extended from array to allow perpage etc.
  class PhotoList < Array
    attr_reader :page, :pages, :perpage, :total
    
    def initialize(flickr_response)
      @page = flickr_response['page'].to_i
      @perpage = flickr_response['perpage'].to_i
      @total = flickr_response['total'].to_i
      @pages = flickr_response['pages'].to_i
      
      @photo = flickr_response['photo']

      super Photo.new(@photo, self) if @photo.is_a? Hash
      super @photo.collect { |photo| Photo.new(photo) }
    end
  end

end
