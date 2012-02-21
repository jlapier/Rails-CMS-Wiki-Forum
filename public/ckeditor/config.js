/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
  config.toolbar_Common =
  [
      ['Maximize'],
      ['Bold','Italic','Underline'],
      ['Link','Unlink','Anchor','NumberedList','BulletedList'],
      ['Outdent','Indent','JustifyLeft','JustifyCenter','JustifyRight','Format'],
      ['Find','Replace'],
      ['Image', 'Table'],
      ['Source']
  ];
  config.toolbar_Mid =
  [
    ['Save', 'Preview'],
    ['PasteText','PasteFromWord','-','Print', 'SpellChecker', 'SpellCheck'],
    ['Find','Replace'],
    ['NumberedList','BulletedList','-','Outdent','Indent'],
    ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
    ['ShowBlocks', 'Source', 'RemoveFormat', 'Maximize'],
    ['Link','Unlink','Image', 'Flash', 'Table'],
    '/',
    ['Bold','Italic','Underline'],
    ['Format','Font','FontSize','TextColor','BGColor']
  ];
  config.toolbar_Newbie = [
    ['Bold','Italic', '-', 'NumberedList', 'BulletedList','-', 'Link',
    'Unlink', 'SpellCheck', '-', 'PasteText', 'PasteFromWord']
  ];
  
	config.uiColor = '#819033';
	config.toolbar = 'Common'
  config.enterMode = CKEDITOR.ENTER_P;
  config.skin = 'v2';
};
