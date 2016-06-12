describe SupportedSource::Util do
  describe "underscore_to_camelcase" do
    it "converts strings from underscore to camelcase" do
      expect(SupportedSource::Util.underscore_to_camelcase('something')).to eq("Something")
      expect(SupportedSource::Util.underscore_to_camelcase('my_test')).to eq("MyTest")
      expect(SupportedSource::Util.underscore_to_camelcase('something_with__more__underscores_')).to eq("SomethingWithMoreUnderscores")
    end
  end

  describe "camelcase_to_underscore" do
    it "converts strings from camelcase to underscore" do
      expect(SupportedSource::Util.camelcase_to_underscore('Something')).to eq("something")
      expect(SupportedSource::Util.camelcase_to_underscore('MyTest')).to eq("my_test")
      expect(SupportedSource::Util.camelcase_to_underscore('AReallyReallyLongWordVAR3')).to eq("a_really_really_long_word_var3")
    end
  end

  describe "#is_email?" do
    it "returns true for valid emails" do
      expect(SupportedSource::Util.is_email?('hello@goodbye.com')).to be(true)
      expect(SupportedSource::Util.is_email?('b@a.co.uk')).to be(true)
      expect(SupportedSource::Util.is_email?('hello+stuff@gmail.com')).to be(true)
      expect(SupportedSource::Util.is_email?('ccc@ddef.fr')).to be(true)
      expect(SupportedSource::Util.is_email?('somebody@mail.something.io')).to be(true)
      expect(SupportedSource::Util.is_email?('somebody@mail.mit.edu')).to be(true)
    end

    it "returns false for valid emails" do
      expect(SupportedSource::Util.is_email?('@goodbye.com')).to be(false)
      expect(SupportedSource::Util.is_email?('b@auk')).to be(false)
      expect(SupportedSource::Util.is_email?('hell@o+stu@ff@gmail.com')).to be(false)
      expect(SupportedSource::Util.is_email?('ccc@ddef')).to be(false)
      expect(SupportedSource::Util.is_email?('mail.something.io')).to be(false)
      expect(SupportedSource::Util.is_email?('asdf@.com')).to be(false)
    end
  end
end
