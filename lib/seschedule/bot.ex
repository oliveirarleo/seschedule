defmodule Seschedule.Bot do
  @bot :seschedule

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start", description: "Start me")
  command("end", description: "End me")
  command("help", description: "Print the bot's help")

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, :help, _msg}, context) do
    answer(context, "Here is your help:")
  end
end
