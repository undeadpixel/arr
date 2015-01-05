module DataHelpers

  def load_data(file)
    File.open("spec/data/#{file}", "r").read
  end

end
