require 'securerandom'

module Helpers
  def make_element(element_type)
    element = Gst::ElementFactory.make(element_type, "#{element_type}-#{SecureRandom.alphanumeric(16)}")
    @elements ||= []
    @elements << element

    element
  end

  def decode_bin_link(src, video_sink_pad, audio_sink_pad)
    src.signal_connect("pad-added") do |_, pad|
      caps = pad.current_caps
      structure = caps.get_structure(0)
      mime_type = structure.name

      if mime_type.include?("video/x-raw")
        pad.link(video_sink_pad.get_static_pad("sink"))
      elsif mime_type.include?("audio/x-raw")
        pad.link(audio_sink_pad.get_static_pad("sink"))
      end
    end
  end
end
