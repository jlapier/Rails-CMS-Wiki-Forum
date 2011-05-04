/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
  config.toolbar_TACS =
  [
      ['Maximize'],
      ['Bold','Italic','Underline'],
      ['Link','Unlink','Anchor'],
      ['NumberedList','BulletedList'],
      ['Outdent','Indent'],
      ['JustifyLeft','JustifyCenter','JustifyRight','Format'],
      ['Find','Replace'],
      ['Source']
  ];
	config.uiColor = '#819033';
	config.toolbar = 'TACS'
  config.enterMode = CKEDITOR.ENTER_P;
};
