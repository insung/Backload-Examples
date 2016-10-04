/*
 * jQuery File Upload Plugin JS Example 8.9.1
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

/* global $, window */

$(function () {
  'use strict';

  // In this example we use a custom controller
  var url = '/FileUploadHandler.ashx?objectContext=Uploads';

  // Initialize the jQuery File Upload widget:
  $('#fileupload').fileupload({
    url: url
  })

  // Load existing files:
  $('#fileupload').addClass('fileupload-processing');
  $.ajax({
    // Uncomment the following to send cross-domain cookies:
    // xhrFields: {withCredentials: true},
    url: url,
    dataType: 'json',
    context: $('#fileupload')[0]
  }).always(function () {
    $(this).removeClass('fileupload-processing');
  }).done(function (result) {
    $(this).fileupload('option', 'done')
        .call(this, $.Event('done'), { result: result });
  });
});
