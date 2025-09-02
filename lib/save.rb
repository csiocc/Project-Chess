require "json"

module SaveGame

  def self.save(save_name, save_value)
    f = File.new 'saves/tempfile', 'w'
    f.write "#{save_value}"
    f.close

    if File.exist? "saves/#{save_name}.json"
      p "name allready exist"
    else
      File.rename 'saves/tempfile', "saves/#{save_name}.json"
      if File.exist? "saves/#{save_name}.json" # checks if save_name allready exists and return successful if yes
        p "Save successful"
        p "saved as '#{save_name}'"
      end
    end
  end

  def self.load(load_name)
    if File.exist? "saves/#{load_name}.json"
      system "clear"
      load_name = "saves/#{load_name}.json"
      load_file = File.read(load_name)
      board = Board.from_json(load_file)
      p "successfully loaded"
      p "#{load_name}"
      return board
    end
  end

  def self.delete_save(del_name)
    File.delete("saves/#{del_name}.json")
    p "'#{del_name}' deleted."
  end

end

