describe Supso do
  describe "#detect_all_npm_projects!" do
    it "correctly interprets npm projects using Super Source" do
      json = %q(
{
  "name": "root_project",
  "version": "1.0.0",
  "dependencies": {
    "something_with_supso": {
      "version": "1.0.0",
      "from": "../js_supso_test",
      "resolved": "file:../js_supso_test",
      "dependencies": {
        "doesnt_use_supso": {
          "version": "1.8.3"
        },
        "dependency-with-supso": {
          "version": "1.8.3",
          "dependencies": {
            "super-source": {
              "version": "0.8.1"
            }
          }
        },
        "super-source": {
          "version": "0.8.1",
          "from": "../super_source/js",
          "resolved": "file:../super_source/js",
          "dependencies": {
            "app-root-path": {
              "version": "1.2.1",
              "from": "app-root-path@>=1.2.1 <2.0.0",
              "resolved": "https://registry.npmjs.org/app-root-path/-/app-root-path-1.2.1.tgz"
            }
          }
        }
      }
    },
    "another-without-supso": {
      "version": "2.1.2"
    }
  }
}
).strip
      expect(Supso::Util).to receive(:has_command?).with('npm').at_least(1).and_return(true)
      expect(Supso::Javascript).to receive(:npm_list_command_response).and_return(json)
      Supso::Project.projects = []
      Supso::Javascript.detect_all_npm_projects!
      expect(Supso::Project.projects.length).to eq(2)
      expect(Supso::Project.projects.map { |p| p.name }).to include('something_with_supso', 'dependency-with-supso')
    end
  end
end
