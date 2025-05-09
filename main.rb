require "./helpers"
require 'gstreamer'

class GStreamerDemo
  include Helpers

  def initialize
    @pipeline = nil
  end

  def start
    Gst.init

    @pipeline = Gst::Pipeline.new("rtmp_overlay_pipeline")

    source = make_element("uridecodebin")
    source.force_sw_decoders = true

    source.uri = "rtmp://live.kaukus.no/local/gstreamer-demo"

    videoconverter = make_element("videoconvert")
    audioconverter = make_element("audioconvert")

    videoqueue = make_element("queue")
    audioqueue = make_element("queue")
    videosink = make_element("autovideosink")
    audiosink = make_element("autoaudiosink")

    @pipeline.add(source, videoconverter, videoqueue, videosink, audioconverter, audioqueue, audiosink)


    decode_bin_link(source, videoqueue.get_static_pad("sink"), audioqueue.get_static_pad("sink"))

    videoqueue.link(videoconverter)
    audioqueue.link(audioconverter)

    audioconverter.link(audiosink)
    #videoconverter.link(videosink)


    videoflip = make_element("videoflip")
    @pipeline.add(videoflip)

    GLib::Timeout.add_seconds(2) do
      puts "Flipping"
      videoflip.set_property("method", videoflip.get_property("method") == 1 ? 0 : 1)
    end

    videoconverter.link(videoflip)
    videoflip.link(videosink)


    @pipeline.set_state(Gst::State::PLAYING)

  end

  def stop
    @pipeline&.set_state(Gst::State::NULL)
  end
end

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

