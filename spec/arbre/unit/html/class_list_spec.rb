require 'spec_helper'

describe Arbre::HTML::ClassList do

  describe ".build_from_string" do

    it "should build a new list from a string of classes" do
      list = Arbre::HTML::ClassList.build_from_string("first second")
      list.size.should == 2

      list.to_a.sort.should == %w{first second}
    end

  end

end
