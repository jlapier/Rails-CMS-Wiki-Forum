require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class DummyClass
  include HtmlGenerator
end

describe HtmlGenerator do
  before(:each) do
  end

  describe "when getting html for list_categories" do
    it "should work when no categories found" do
      expected = '<ul><li><em>No categories were found</em></li></ul>'

      DummyClass.list_categories_to_html.should equal_without_whitespace expected
    end

    it "should work when categories are found" do
      (1..3).each { |n| Category.create :name => "Some category #{n}" }

      expected = <<-END
        <ul>
          <li class=\"homelink\"><a href="/">Home</a></li>
          <li class=\"category_1\"><a href="/categories/1">Some category 1</a></li>
          <li class=\"category_2\"><a href="/categories/2">Some category 2</a></li>
          <li class=\"category_3\"><a href="/categories/3">Some category 3</a></li>
        </ul>
      END

      DummyClass.list_categories_to_html({:use_homelink => true}).should equal_without_whitespace expected
    end
  end

  describe "when getting html for list_pages_in_category" do
    it "should work when category not found" do
      expected = '<ul><li><em>No category found: test</em></li></ul>'

      DummyClass.list_pages_in_category_to_html({:other_params => 'test'}).should equal_without_whitespace expected
    end

    it "should work when category found but has no pages" do
      cat = Category.create :name => "Some category 1"
      expected = <<-END
        <ul>
          <li>
            <em>No pages were found in the category: #{cat.name}</em>
          </li>
        </ul>
      END

      DummyClass.list_pages_in_category_to_html({:other_params => cat.name}).should equal_without_whitespace expected
    end

    it "should work when category found and has a page" do
      cat = Category.create :name => "Some category 1"
      cp = ContentPage.create! :name => "Page one", :is_preview_only => false
      cp.categories << Category.find(:first)
      cp.save!

      expected = '<ul><li><a href="/">Home</a></li>
        <li><a href="/content_pages/1">Page one</a></li></ul>'

      DummyClass.list_pages_in_category_to_html({:other_params => cat.name, :use_homelink => true}).should
        equal_without_whitespace expected
    end
  end

  describe "when getting html for tree_categories" do
    it "should work when no categories found" do
      expected = "<ul><li><em>No categories were found</em></li></ul>"

      DummyClass.tree_categories_to_html.should equal_without_whitespace expected
    end

    it "should work when categories are found" do
      (1..3).each { |n| Category.create :name => "Some category #{n}" }
      cp = ContentPage.create! :name => "Page one", :is_preview_only => false
      cp.categories << Category.find(:first)
      cp.save!

      expected = <<-END
        <ul>
          <li><a href="/categories/1">Some category 1</a>
            <ul>
              <li><a href="/content_pages/1">Page one</a></li>
            </ul>
          </li>
          <li>
            <a href=\"/categories/2\">Some category 2</a>
            <ul></ul>
          </li>
          <li>
            <a href=\"/categories/3\">Some category 3</a>
            <ul></ul>
          </li>
        </ul>
      END
      DummyClass.tree_categories_to_html.should equal_without_whitespace expected
    end

    it "should work when categories are specified" do
      (1..3).each { |n| Category.create :name => "Some category #{n}" }

      expected = <<-END
        <ul>
          <li>
            <a href="/categories/1">Some category 1</a>
            <ul></ul>
          </li>
          <li>
            <a href=\"/categories/3\">Some category 3</a>
            <ul></ul>
          </li>
        </ul>
      END
      DummyClass.tree_categories_to_html(:other_params => ['Some category 1', 'Some category 3']).should equal_without_whitespace expected
    end
  end

  describe "when getting html for link_page" do
    it "should get a found page" do
      cp = ContentPage.create! :name => "Page one", :is_preview_only => false
      expected = '<a href="/content_pages/1">Page one</a>'
      DummyClass.link_page_to_html(:other_params => 'Page one').should equal_without_whitespace expected
    end

    it "should work for not found page" do
      expected = '<em>No page found named: Page none</em>'
      DummyClass.link_page_to_html(:other_params => 'Page none').should equal_without_whitespace expected
    end
  end

  describe "when getting html for link_category" do
    it "should get a found category" do
      Category.create :name => "Some category 1"
      expected = '<a href="/categories/1">Some category 1</a>'
      DummyClass.link_category_to_html(:other_params => 'Some category 1').should equal_without_whitespace expected
    end

    it "should work for not found category" do
      expected = '<em>No category found named: Category none</em>'
      DummyClass.link_category_to_html(:other_params => 'Category none').should equal_without_whitespace expected
    end
  end



  describe "when getting html for search box" do
    it "should work for a plain search box" do
      expected = <<-END
        <form action="/content_pages/search" method="get" name="site_search_box" id="site_search_box">
          <input type="text" name="q" size="20">
          <input type="submit" value="search">
        </form>
      END

      DummyClass.search_box_to_html.should equal_without_whitespace expected
    end

    it "should work for a search box with a category list option" do
      expected = <<-END
        <form action="/content_pages/search" method="get" name="site_search_box" id="site_search_box">
          <input type="text" name="q" size="20">
          <select name="c_id">
            <option value="0">Any category</option>
            <option value="1">Some category1</option>
          </select>
          <input type="submit" value="search">
        </form>
      END

      pending "add the with_category_list option" do
        DummyClass.search_box_to_html(:with_category_list => true).should equal_without_whitespace expected
      end
    end
  end

  describe "when getting html for calendars" do
    it "should work for a plain calendar" do
      expected = <<-END
        <div id="calendar" class="calendars"></div>
        
        <div style="clear:both"></div>
        
        <div id="event_quick_description" style="display:none"></div>
        
        <script type="text/javascript">
        $(document).ready(function() {
          $('#calendar').fullCalendar({ 
            header: { left: 'prev,next today', center: 'title', right: 'month,agendaWeek,agendaDay' },
            editable: false, 
            events: '/event_calendar/events', 
            height: 500, 
            aspectRatio: 1,
            eventMouseover: updateEventDescription
          });
        });
        </script>
      END

      DummyClass.calendar_to_html.should equal_without_whitespace expected
    end
  end
end

