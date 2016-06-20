describe Supso::Util do
  describe "underscore_to_camelcase" do
    it "converts strings from underscore to camelcase" do
      expect(Supso::Util.underscore_to_camelcase('something')).to eq("Something")
      expect(Supso::Util.underscore_to_camelcase('my_test')).to eq("MyTest")
      expect(Supso::Util.underscore_to_camelcase('something_with__more__underscores_')).to eq("SomethingWithMoreUnderscores")
    end
  end

  describe "camelcase_to_underscore" do
    it "converts strings from camelcase to underscore" do
      expect(Supso::Util.camelcase_to_underscore('Something')).to eq("something")
      expect(Supso::Util.camelcase_to_underscore('MyTest')).to eq("my_test")
      expect(Supso::Util.camelcase_to_underscore('AReallyReallyLongWordVAR3')).to eq("a_really_really_long_word_var3")
    end
  end

  describe "#is_email?" do
    it "returns true for valid emails" do
      expect(Supso::Util.is_email?('hello@goodbye.com')).to be(true)
      expect(Supso::Util.is_email?('b@a.co.uk')).to be(true)
      expect(Supso::Util.is_email?('hello+stuff@gmail.com')).to be(true)
      expect(Supso::Util.is_email?('ccc@ddef.fr')).to be(true)
      expect(Supso::Util.is_email?('somebody@mail.something.io')).to be(true)
      expect(Supso::Util.is_email?('somebody@mail.mit.edu')).to be(true)
    end

    it "returns false for valid emails" do
      expect(Supso::Util.is_email?('@goodbye.com')).to be(false)
      expect(Supso::Util.is_email?('b@auk')).to be(false)
      expect(Supso::Util.is_email?('hell@o+stu@ff@gmail.com')).to be(false)
      expect(Supso::Util.is_email?('ccc@ddef')).to be(false)
      expect(Supso::Util.is_email?('mail.something.io')).to be(false)
      expect(Supso::Util.is_email?('asdf@.com')).to be(false)
    end
  end

  describe "#sanitize_command" do
    it "strips out anything that isnt alphanumeric, underscore, or dash" do
      expect(Supso::Util.sanitize_command('bad rm -rf /')).to eq('badrm-rf')
      expect(Supso::Util.sanitize_command('\xeb\x3e\x5b\x50\x54')).to eq('xebx3ex5bx50x54')
      expect(Supso::Util.sanitize_command('supso')).to eq('supso')
      expect(Supso::Util.sanitize_command('bad dd if=/dev/random of=/dev/sda')).to eq('badddifdevrandomofdevsda')
    end
  end
end
