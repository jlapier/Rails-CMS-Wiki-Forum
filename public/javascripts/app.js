// use to give the preview of details for an event below a calendar
var updateEventDescription = function(event, jsEvent) {
  $("#event_quick_description").empty();
  $("#event_quick_description").append(
    $("<h3/>").append(
      $('<a/>', { text : event.title+' ('+event.eventType+')', href : event.url })
    )
  ).append(event.details);
  $("#event_quick_description").show();
  $("#event_mini_description").empty();
  $("#event_mini_description").append(
      $('<div/>', { style : 'float:right' }).append(
        $('<a/>', { text : 'X', onclick : '$("#event_mini_description").hide()' })
      )
  ).append(event.brief);
  $("#event_mini_description").show();
  $("#event_mini_description").position({
    my: "left top", at: "center bottom", of: $(jsEvent.target) });
}

function htmlDecode(value){ 
  return $('<div/>').html(value).text(); 
}

jQuery(function($) {
  $('body').bind('click', function() { $('.menu_hidable').hide() });
  $('ul.events').attach(Collapsible);
  $('a.show_hide_link').attach(ShowHideLink);
  $('a.menu_show_hide_link').attach(ShowHideLink, {my_highlight_class : 'menu_highlight'});
  $('a.view_events').attach(EventView);
  $('div.links').attach(MagicButtons);
  $('div.links').attach(ecDynamicForm, {
    formElement: $('#link_dynamic_form')
  });
});

/*
http://www.learningjquery.com/2007/08/clearing-form-data
*/
$.fn.clearForm = function() {
  return this.each(function() {
    var type = this.type, tag = this.tagName.toLowerCase();
    if (tag == 'form')
      return $(':input',this).clearForm();
    if (type == 'text' || type == 'password' || tag == 'textarea')
      this.value = '';
    else if (type == 'checkbox' || type == 'radio')
      this.checked = false;
    else if (tag == 'select')
      this.selectedIndex = -1;
  });
};


var CMSApp = {
  getRecentMessages : function(container) {
    $.getJSON('/forums/recent_messages', function(data) {
        var message_ul = $('<ul/>', { 'class' : 'recent_discussions' });
        var items = [];

        $.each(data, function(key, val) {
          var m_post = val.message_post
          var s_div = $('<div/>', { 'class' : 'subject' });
          var link = $('<a/>', { html: m_post.subject, 
            href: '/forums/' + m_post.forum_id + '/message_posts/' + m_post.id } );
          s_div.append(link);
          s_div.append(' by ' + m_post.poster);

          d_div = $('<div/>', { 'class' : 'date_and_forum',
            html:'<em>' + m_post.post_time + '</em> on ' + m_post.forum_name});
          
          var li = $('<li/>');
          li.append(s_div);
          li.append(d_div);
          message_ul.append(li);
        });

        container.html(message_ul);
    });
  },

  getRecentWikiComments : function(container) {
    $.getJSON('/wikis/recent_comments', function(data) {
        var comments_ul = $('<ul/>', { 'class' : 'recent_wiki_comments' });
        var items = [];

        $.each(data, function(key, val) {
          var w_c = val.wiki_comment;
          var w_c_div = $('<div/>', { 'class' : 'wiki_chatter', 
            html : w_c.to_html });
          
          var li = $('<li/>');
          li.append(w_c_div);
          comments_ul.append(li);
        });

        container.html(comments_ul);
    });
  }
}
