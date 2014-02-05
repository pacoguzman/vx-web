require 'spec_helper'

describe String do
  context "#to_safe_utf8" do

    it "should work with valid unicode strings" do
      %w{ Раз Два Три }.map(&:to_safe_utf8).should eq %w{ Раз Два Три }
    end

    it "should fix invalid multibyte characters" do
      expect("Men\xFC".to_safe_utf8).to eq "Men�"
    end

  end
end
