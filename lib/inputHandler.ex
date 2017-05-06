defmodule ConsoleMenu.InputHandler do

  def request_menu_selection(message \\ "") do
    with {index, _} <- Integer.parse(IO.gets(message)), do:
      index
  end

end
