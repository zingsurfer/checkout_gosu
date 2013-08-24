class Level

  ROWS = 11
  COLUMNS = 15

  def initialize(window, level)
    @level                  = level
    @window                 = window
    @window.caption         = "RailsGirls: The Mysteries of Ruby"
    @background_music       = Song.new(@window, "media/4pm.mp3")
    @map                    = Map.new(@window, ROWS, COLUMNS)
    @player, @gems, @bugs, @key = read_level(level, ROWS, COLUMNS)
    @background_music.play(true) unless ENV['DISABLE_SOUND'] == 'true'
  end

  def update
    @player.move_left   if @window.button_down? KbLeft
    @player.move_right  if @window.button_down? KbRight
    @player.move_up     if @window.button_down? KbUp
    @player.move_down   if @window.button_down? KbDown
    @player.collect_gems(@gems)
    @player.collect_key(@key) unless @player.key_collected?
    if hit_by_bug?
      game_over
    elsif @gems.size == 0 && @player.key_collected?
      level_finished
    end
  end

  def draw
    @map.draw
    (@gems + @bugs).each do |e|
      e.draw
    end
    @key.draw unless @player.key_collected?
    @player.draw
  end

  def button_down(id)
    if id == Gosu::KbEscape || id == Gosu::KbQ then
      @window.show_main_menu
    end
  end

  def hit_by_bug?
    @bugs.any? do |bug|
      Gosu::distance(@player.x, @player.y, bug.x, bug.y) < 35
    end
  end

  def level_finished
    puts 'finished level'
    @window.show_level_finished_screen
  end

  def game_over
    puts 'game over'
    @window.show_game_over_screen
  end

  def read_level(level, rows, columns)
    player = nil
    gems   = []
    bugs   = []
    key    = nil
    level  = File.open(level[:path]).readlines[1..-1]

    rows.times do |row|
      columns.times do |column|
        case level[row][column]
          when 'P'
            player = Player.new(@window, column, row)
          when 'G'
            gems << ColoredGem.new(@window, column, row)
          when 'B'
            bugs << Bug.new(@window, column, row)
          when 'K'
            key = Key.new(@window, column, row)
          else
            #nothing
        end
      end
    end

    [player, gems, bugs, key]
  end
end
