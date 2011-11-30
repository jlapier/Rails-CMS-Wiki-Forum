require 'spec_helper'

describe ErrorsController do

  describe "GET 'routing'" do
    it "returns http success" do
      get 'routing'
      response.should be_success
    end
  end

end
