var AssetBrowser = Class.create({
  initialize: function(grouping, folder, for_content) {
    AssetBrowser.current_grouping = grouping;
    AssetBrowser.dl = $('asset-browser');
    AssetBrowser.setContentNodeForm('has-assets-form');
    AssetBrowser.dts = AssetBrowser.dl.select('dt');
    AssetBrowser.open_folder = folder;
    AssetBrowser.for_content = (for_content || false);
        
    AssetBrowser.dts.each(function(dt) {
      dt.dd = dt.next('dd');
      if (dt.dd) {
        dt.dd.hide();
        dt.onclick = function() {
          AssetBrowser.closeInfo();

          if(!this.dd.visible() && !dt.dd.down('ul li'))
            AssetBrowser.loadFilesByFolder(dt.innerHTML, dt.dd.down('ul').id);



          this.dd.toggle();
          if (AssetBrowser.current_content != this.dd) {
            if (AssetBrowser.current_content != null && AssetBrowser.current_content.visible()) {
              AssetBrowser.current_content.toggle();
            }
            AssetBrowser.current_content = this.dd;
          }
        };
        new Renameable(dt, 0.7);
      }
    });
    AssetBrowser.openContent();
  }
});

Object.extend(AssetBrowser, {
 
  openContent: function() {
    type = this.open_folder;
    if (type) {
      dt = this.dl.down('#'+type);
      if (dt) { dt.onclick(); }      
    }
  },

  openInfo: function(id, anchor) {
     
    this.closeInfo();
    list = $(anchor).up('ul');
    list.hide();
    list.insert({after: '<div id="asset-info"></div>'});
    this.current_list = list;
    this.current_info = list.next();

    new Ajax.Request('/admin/assets/' + id, { method: 'get',
                                              asynchronous:true, 
                                              evalScripts:true } );
  },
  
  closeInfo: function() {
    if (this.current_list) {
      this.current_list.show();
      this.current_info.remove();
    }
    this.current_list = null;
    this.current_info = null;
  },
  
  closeThumbnail: function() {
    key = Object.keys(SWFUpload.instances).last();
    SWFUpload.instances[key].destroy();
    this.closeInfo();
  },
  
  assetAction: function(asset) {
    $('asset-upload-form').reset();
    if (this.contentNodeForm) {
      this.addAssetToContentNode(asset);
    } else {
      this.destroyAsset(asset);
    }
  },
  
  destroyAsset: function(asset) {
    if (confirm('Are you sure you wish to delete the asset \'' + asset.filename + ' \'?')) {
      new Ajax.Request('/admin/assets/'+ asset.id, { method: 'delete',
                                                     asynchronous:true, 
                                                     evalScripts:true,
                                                     parameters: { content_type: asset.content_type, authenticity_token: AJ.authenticity_token() } } );
      
      asset_li = $('browser-asset-' + asset.id);
      asset_list = asset_li.up('ul');
      asset_li.remove();
      if (asset_list.empty()) {
        asset_list.up('dd').previous().remove();
        asset_list.up('dd').remove();
      }
      if (this.contentNodeForm) {
        this.removeAssetFromContentNode(asset.id);
      }  
      
    }
  },
  
  loadFilesByFolder: function(folder_name, folder_id){
      new Ajax.Request('/admin/assets/' + this.current_grouping.replace(/^by_/, ''), { method: 'get',
                                                     asynchronous:true, 
                                                     parameters: { for_content: AssetBrowser.for_content, format: 'html', category: folder_name, authenticity_token: AJ.authenticity_token() },
                                                     onSuccess: function(response){ $(folder_id).update(response.responseText); } } );
    
  },
  
  // Fire once a asset has been uploaded
  uploadedAsset: function(asset) {
    type = Object.keys(asset).first();
    $('asset-upload-form').reset();
    if (this.contentNodeForm) {
      this.addAssetToContentNode(asset[type]);
    }
    if (asset[type]) {
      switch (this.current_grouping){
        case 'by_content_type':
        this.open_folder = asset[type].content_type.replace(/\W+/,'-');
        break;
        case 'by_category':
        this.open_folder = asset[type].category;
        break;
      }
    }
  },
  
  reload: function(grouping) {
    if (grouping) {
      this.current_grouping = grouping;
    }
    new Ajax.Request('/admin/assets/'+this.current_grouping, { method: 'get',
                                        asynchronous:true, 
                                        evalScripts:true,
                                        parameters: { for_content: this.contentNodeForm != null,
                                                      folder: this.open_folder },
                                        onSuccess: init_asset_category_auto_complete } );
    
  },
  
  setContentNodeForm: function(id) {
    this.contentNodeForm = $(id);
    if (this.contentNodeForm) {
      this.contentNodeForm.model_name = this.contentNodeForm.className.split('_').slice(1,this.contentNodeForm.className.split('_').length).join('_');
      this.setUpAssetList();
      this.contentNodeForm.addAssetIDs = function() {
        $$('input.asset_id').invoke('remove');
        assets = $$('#attach-asset-list li');
        
        if (assets.size() == 0) {
            $(this).insert('<input type="hidden" name="' + this.model_name + '[asset_ids]" class="asset_id" value="" />');
        } else {
          assets.each(function(li) {
            asset_id = li.id.split('-').last();
            this.insert('<input type="hidden" name="' + this.model_name + '[asset_ids][]" class="asset_id" value="' + asset_id + '" />');
          }, this);          
        }
      };
      
      this.contentNodeForm.onsubmit = function() {
        this.addAssetIDs();
        return true;
      };
      this.contentNodeForm.serialize = function() {
        this.addAssetIDs();
        return Form.serialize(this);
      };
    } 
  },
  
  setUpAssetList: function() {
    Sortable.create('gallery-list');
    Sortable.create('downloads-list');
  },

  addAssetToContentNode: function(asset) {
    if (!$('asset-' + asset.id)) {
      new Ajax.Request('/admin/assets/'+asset.id+'/attach');
    }
  },

  removeAssetFromContentNode: function(asset_id) {
    $('asset-' + asset_id).remove();
  },
  
  rootUrl: function(url){
    if(!url)
      url = window.location.href;
    
    var matches = url.match(/^(?:http:\/\/)?[^\/]+/);
    if(matches.length <1){
      return url;
    }else{
      return matches[0];
    }
  },
  
  // For swfu only
  uploadSuccess: function(fileObj, server_data) {
    AssetBrowser.uploadedAsset(server_data.evalJSON());
  },
  
  uploadComplete: function(fileObj) {
    /* I want the next upload to continue automatically so I'll call startUpload here */
    if (this.getStats().files_queued > 0) {
      this.startUpload();
    } else {
      UploadProgress.finish();
      AssetBrowser.reload();
    }
  }

});

// Load SWFU
var swfu;
Event.observe(window, 'load', function() {
  if ($('asset-browser')) {
    file_size_limit = '7 MB';
    form = $('asset-upload-form');
    form.insert({after: '<div id="flash-button"></div><span>upto ' + file_size_limit + '</span>'});
    js_path =  form.action.split('?').join('.js?');
    swfu = new SWFUpload({
      // Create the custom swfupload_photos_path in the routes.rb file
      // Session name must match with environment.rb 
      upload_url : js_path,
      flash_url : '/flash/swfupload.swf',
      file_post_name: 'asset[uploaded_data]', 

      file_size_limit : file_size_limit,
      file_upload_limit : 0,

      file_queue_error_handler : UploadHandler.fileQueueError,
      file_dialog_complete_handler : UploadHandler.fileDialogComplete,
      upload_progress_handler : UploadHandler.uploadProgress,
      upload_start_handler: UploadHandler.uploadStart,
      upload_error_handler : UploadHandler.uploadError,
      upload_success_handler : AssetBrowser.uploadSuccess,
      upload_complete_handler : AssetBrowser.uploadComplete,
      custom_settings : { 
        upload_form : 'asset-upload-form'
      },
      
      button_placeholder_id: 'flash-button',
      button_height: 19,
      button_width: 157,
      button_image_url: '/images/admin/file-uploads.png',
      button_action : SWFUpload.BUTTON_ACTION.SELECT_FILES,
      button_disable : false,
      button_window_mode : SWFUpload.WINDOW_MODE.TRANSPARENT,

      debug: false

    }); 
    if (swfu) {
      form.onsubmit = function(){return false;};
      $('upload-elements').remove();
    }
  }

});

init_asset_category_auto_complete = function() {
  asset_category_field = $('asset_category');
  if (asset_category_field) {
    new Ajax.Request('/admin/assets/categories', { 
      method: 'get',
      onSuccess : function(response) {
        new Autocompleter.Local('asset_category', 'asset_category_complete', response.responseJSON );
      }
    });
  }
};
document.observe('dom:loaded', init_asset_category_auto_complete);

init_edit_asset_form = function() {
  $$('form.edit_asset').first().onsubmit = function(e) {
    this.request({
      onComplete: function() {AssetBrowser.reload();}
    });
    
    return false;
  };
};

var Holdable = Class.create({
  initialize: function(elem, seconds, firer) {
    this.elem = elem;
    this.seconds = seconds;
    if (firer) {
      this.firer = firer; 
    }
    
    this.elem.observe('mousedown', this.starter.bindAsEventListener(this));
    this.elem.observe('mouseup', this.clearTimeout.bindAsEventListener(this));
  },
  
  starter: function() {
    this.clear_id = this.firer.delay(this.seconds, this.elem);
  },
  
  firer: function(elem) {
    alert('NO FIRER!');
  },
  
  clearTimeout: function() {
    window.clearTimeout(this.clear_id);
  }
});

var Renameable = Class.create(Holdable, {
  firer: function(elem) {
    this.text_input = new Element('input', { href: 'text', value: elem.innerHTML }); 
    elem.update(this.text_input);
    this.text_input.focus();
    this.text_input.observe('blur', function() {
      this.replace(this.value);
    });
    this.text_input.observe('change', function() {
      asset_id = elem.id.split('-').last();
      new Ajax.Request('/admin/assets/' + asset_id + '/rename_category' , {
        parameters: { name: this.value  }
      });
    });
  } 
});
var flickr_load_select = function(){
  if($('flickr-image-container')) {
    new Ajax.Request('/admin/flickrs', {method: 'get'});
  }
};
document.observe('dom:loaded', flickr_load_select);