var UploadHandler = {
  fileQueueError: function(fileObj, error_code, message) {
  	try {
  		var error_name = "";
  		switch(error_code) {
  			case SWFUpload.ERROR_CODE_QUEUE_LIMIT_EXCEEDED:
  				error_name = "You have attempted to queue too many files.";
  			case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
  				error_name = "This file is zero bytes, it may be corrupt";
  			break;
  			case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
  				error_name = "The file size is to large";
  			break;
  			case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
  			case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
  			default:
  				image_name = "The file type is not allowed, these are jpg, gif, png";
  			break;
  		};

  		if (error_name !== "") {
  			alert(error_name);
  			return;
  		}

  	} catch (ex) { this.debug(ex); }

  },
  
  fileDialogComplete: function(num_files_queued) {
  		if (num_files_queued > 0) {
  		  UploadProgress.create(this.customSettings.upload_form);
        this.setPostParams($(this.customSettings.upload_form).serialize(true));
  			this.startUpload();
  		}
  },
  
  uploadStart: function(fileObj) {
    UploadProgress.start(fileObj);
  },
  
  uploadProgress: function(fileObj, bytesLoaded) {
		UploadProgress.update(fileObj, bytesLoaded);
  },
  
  uploadSuccess: function(fileObj, server_data) {
    // Override to do something with the file
  },

  uploadComplete: function(fileObj) {
		/*  I want the next upload to continue automatically so I'll call startUpload here */
		if (this.getStats().files_queued > 0) {
			this.startUpload();
		} else {
      UploadProgress.finish();
		}
  },

  uploadError: function(fileObj, error_code, message) {
		switch(error_code) {
			case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
				UploadProgress.errors('Upload Stoped');
			case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
				UploadProgress.errors('Upload limit Exceeded');
			break;
			default:
				UploadProgress.errors(message);
			break;
		}  
  }
};

var UploadProgress = {
  create: function(form) {
    if (!this.uploading) {
      $$('div.progress-bar').invoke('remove'); 
      this.uploadForm = $(form);
      this.uploadForm.insert({ bottom: '<div class="progress-bar"></div>'  });
      this.container = this.uploadForm.down('div.progress-bar');
      this.StatusBar.create(this.container);
      this.uploading = true;  
    }
  },
  
  start: function(fileObj) {
    this.StatusBar.update(0, "Begining upload of " + fileObj.name);
  },


  update: function(fileObj, current) {
    var status = (current / fileObj.size);
    var statusHTML = "<div id='total-loaded'><strong>" + fileObj.name + "</strong> " + status.toPercentage() + "<br>" + current.toHumanSize() + ' of ' + fileObj.size.toHumanSize() + " uploaded.</div>";
    this.StatusBar.update(status, statusHTML);
  },
  
  finish: function() {
    this.uploading = false;
    this.StatusBar.finish();
  },
  
  errors: function(html) {
    this.uploadForm.insert({top: '<div class="upload-errors">' + html + '</div>'});
  },
  
  cancel: function(msg) {
    if(!this.uploading) return;
    this.uploading = false;
    if(this.StatusBar.statusText) this.StatusBar.statusText.innerHTML = msg || 'canceled';
  },
  
  StatusBar: {
    statusBar: null,
    statusText: null,
    statusBarWidth: 500,
  
    create: function(element) {
      this.progress = element;
      this.statusBar  = this._createStatus('status-bar');
      this.statusText = this._createStatus('status-text');
      this.statusText.innerHTML  = '0%';
      this.statusBar.style.width = '0';
    },

    update: function(status, statusHTML) {
      this.statusText.innerHTML = statusHTML;
      this.statusBar.style.width = status.toPercentage();
    },

    finish: function() {
      this.statusText.innerHTML  = 'All files uploaded';
      this.statusBar.style.width = '100%';
    },
    
    _createStatus: function(id) {
      el = this.progress.getElementsByClassName(id)[0];
      if(!el) {
        el = new Element('span', { 'class': id });
        this.progress.appendChild(el);
      }
      return el;
    }
  }

};

Number.prototype.bytes     = function() { return this; };
Number.prototype.kilobytes = function() { return this *  1024; };
Number.prototype.megabytes = function() { return this * (1024).kilobytes(); };
Number.prototype.gigabytes = function() { return this * (1024).megabytes(); };
Number.prototype.terabytes = function() { return this * (1024).gigabytes(); };
Number.prototype.petabytes = function() { return this * (1024).terabytes(); };
Number.prototype.exabytes =  function() { return this * (1024).petabytes(); };
['byte', 'kilobyte', 'megabyte', 'gigabyte', 'terabyte', 'petabyte', 'exabyte'].each(function(meth) {
  Number.prototype[meth] = Number.prototype[meth+'s'];
});

Number.prototype.toPrecision = function() {
  var precision = arguments[0] || 2;
  var s         = Math.round(this * Math.pow(10, precision)).toString();
  var pos       = s.length - precision;
  var last      = s.substr(pos, precision);
  return s.substr(0, pos) + (last.match("^0{" + precision + "}$") ? '' : '.' + last);
};

// (1/10).toPercentage()
// # => '10%'
Number.prototype.toPercentage = function() {
  return Math.ceil(this * 100) + '%';
};

Number.prototype.toHumanSize = function() {
  if(this < (1).kilobyte())  return this + " Bytes";
  if(this < (1).megabyte())  return (this / (1).kilobyte()).toPrecision()  + ' KB';
  if(this < (1).gigabytes()) return (this / (1).megabyte()).toPrecision()  + ' MB';
  if(this < (1).terabytes()) return (this / (1).gigabytes()).toPrecision() + ' GB';
  if(this < (1).petabytes()) return (this / (1).terabytes()).toPrecision() + ' TB';
  if(this < (1).exabytes())  return (this / (1).petabytes()).toPrecision() + ' PB';
                             return (this / (1).exabytes()).toPrecision()  + ' EB';
};
