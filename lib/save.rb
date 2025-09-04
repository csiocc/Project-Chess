require "json"

module SaveGame

  def self.save(save_name, save_value)
    f = File.new 'saves/tempfile', 'w'
    f.write "#{save_value}"
    f.close

    file_path = "saves/#{save_name}.json"

    (0..6).each do |i|
      new_save_name = i.zero? ? save_name : "#{save_name}#{i}"
      file_path = "saves/#{new_save_name}.json"

      unless File.exist?(file_path)
        save_name = new_save_name
        break
      end
    end
      
    File.rename 'saves/tempfile', "saves/#{save_name}.json"
      if File.exist? "saves/#{save_name}.json" 
        p "Save successful"
        p "saved as '#{save_name}'"
      end
    
  end

  def self.load(load_name)
    file_to_load = "saves/#{load_name}.json"
    if File.exist?(file_to_load)
      load_file = File.read(file_to_load)
      board, game_state = Board.from_json(load_file)
      p "loaded:"
      p "#{load_name}"
      return [board, game_state]
    end
  end

  def self.get_save_files
    Dir.glob('saves/*.json').map { |f| File.basename(f, ".json") }
  end

  def self.delete_save(del_name)
    p "save deletesave triggered"
    File.delete("saves/#{del_name}.json")
    p "'#{del_name}' deleted."
  end

end

