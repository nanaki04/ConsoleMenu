defmodule ConsoleMenu.InputHandler do

  def request_menu_selection(message // "") do
    Integer.parse(IO.gets message)
  end

end
