/*
Copyright (c) 2003-2009, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
  config.skin = 'v2';

	config.toolbar = 'Basic';

  config.toolbar_Mid =
  [
      ['Save', 'Preview'],
      ['PasteText','PasteFromWord','-','Print', 'SpellChecker'],
      ['Find','Replace'],
      ['NumberedList','BulletedList','-','Outdent','Indent'],
      ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
      ['ShowBlocks', 'Source', 'RemoveFormat', 'Maximize'],
      '/',
      ['Bold','Italic','Underline'],
      ['Format','Font','FontSize','TextColor','BGColor'],
      ['Link','Unlink','Image', 'Flash', 'Table']
  ];
};
