require "gosu"

class Window < Gosu::Window
  include Gosu
  Vector2D = Struct.new(:x, :y, :z)
  INCHES = 0
  FEET   = 1
  MM     = 2
  CM     = 3
  M      = 4

  def initialize
    super(800, 800, fullscreen: false)
    self.caption = "Field Measuring Tool - FTC Rovor Ruckus"
    @field_image = Gosu::Image.new("media/rovor_ruckus_field.png", retro: false)
    @font        = Gosu::Font.new(20, name: Gosu.default_font_name, bold: true)
    @distance    = 0

    @scale = self.width.to_f / @field_image.width.to_f
    @origin = Vector2D.new((@field_image.width/2), (@field_image.height/2))

    @render_ui = true
    @text = ""

    # WHAT UNIT TO DISPLAY
    @unit = 0
    @pixel_to_inch = 3.25
    @pixel_to_mm   = @pixel_to_inch / 25.4 # INCH TO MM

    # Round
    @r = 2
  end

  def draw
    # FIELD BACKGROUND IMAGE
    @field_image.draw(0,0,0, @scale, @scale)
    return unless @render_ui

    # BLUE HALF OF FIELD
    draw_rect(0,0, (@field_image.width * @scale)/2, self.height, Color.rgba(0,0,255, 15), 1)
    # RED HALF OF FIELD
    draw_rect((@field_image.width * @scale)/2,0, (@field_image.width * @scale)/2, self.height, Color.rgba(255,0,0, 15), 1)

    # ORIGIN POINT
    draw_rect(@scale * @origin.x  - 4, @scale * @origin.y - 4, 8, 8, Color::GREEN, 2)
    draw_rect(@scale * @origin.x  - 2, @scale * @origin.y - 2, 4, 4, Color::BLUE, 2)

    # LINE FROM ORIGIN TO MOUSE
    angle = Gosu.angle(mouse_x, mouse_y, @scale * @origin.x, @scale * @origin.y)

    rotate(angle, @scale * @origin.x, @scale * @origin.y) do
      draw_rect(@scale * @origin.x - 1, @scale * @origin.y, 3, @distance.abs * @scale, Color::WHITE, 4)
    end

    # DRAW TEXT
    width = @font.text_width(@text) # WIDTH OF TEXT
    x = mouse_x - width/2
    y = mouse_y - (@font.height+10)
    if mouse_x + width/2 > self.width
      x = self.width - width
    elsif x < 0
      x = 0
    end

    y = 0 if y < 0 # only need to account for top as text is drawn above mouse

    @font.draw_text(@text, x, y, 10, 1,1, Color.rgb(255,127,0))

    # TEXT BACKGROUND
    draw_rect(x-2, y-2, width+4, @font.height+4, Color.rgba(0,0,0, 150), 9)
  end

  def update
    @distance = Gosu.distance(@origin.x, @origin.y, mouse_x / @scale, mouse_y / @scale)
    @distance_in_inches = (@distance / @pixel_to_inch).round(@r)
    @distance_in_mm = (@distance / @pixel_to_mm).round(@r)

    if @unit == INCHES
      @text = "#{@distance_in_inches} inches"
    elsif @unit == FEET
      @text = "#{(@distance_in_inches / 12).round(@r)} feet"
    elsif @unit == MM
      @text = "#{@distance_in_mm} mm"
    elsif @unit == CM
      @text = "#{(@distance_in_mm / 10).round(@r)} cm"
    elsif @unit == M
      @text = "#{(@distance_in_mm / 1000).round(@r)} meters"
    else
      @text = "#{@distance.round(@r)} pixels"
    end
  end

  def needs_cursor?
    true
  end

  def button_up(id)
    case id
    when Gosu::KbEscape
      close
    when Gosu::MsLeft
      @origin.x, @origin.y = mouse_x / @scale, mouse_y / @scale
    when Gosu::Kb0
      @origin = Vector2D.new((@field_image.width/2), (@field_image.height/2))
    when Gosu::KbTab
      @unit+=1
      @unit = 0 if @unit > 5
    when Gosu::KbBacktick
      @render_ui = !@render_ui
    end
  end
end

Window.new.show