require 'gstreamer'
require "./helpers"
require "./demo"

demo = GStreamerDemo.new

begin
  demo.start
  puts "Streaming started. Press Ctrl+C to stop."
  @main_loop = GLib::MainLoop.new(nil, false)
  @main_loop.run

rescue Interrupt
  demo.stop
  @main_loop&.quit
  puts "Stream stopped."
end

