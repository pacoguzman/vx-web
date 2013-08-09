module ReadFixtureSpecSupport
  def read_fixture(name)
    File.read Rails.root.join("spec/fixtures").join(name)
  end

  def read_json_fixture(name)
    JSON.parse read_fixture(name)
  end
end
