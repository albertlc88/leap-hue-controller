require 'hue'

class Lighter
  MAX_HUE = 65535
  FPS = 30

  attr_reader :transiting

  def initialize(transition_duration:)
    @transition_duration = transition_duration
    @transiting = false
    @light = Hue::Client.new.lights.first
  end

  def light(hue:, saturation: nil, brightness: nil)
    @transiting = true
    EM.add_timer @transition_duration do
      @transiting = false
    end
    params = {hue: hue}
    params[:sat] = saturation if saturation
    params[:bri] = brightness if brightness
    $stderr.puts params.inspect if $DEBUG or $VERBOSE
    @light.set_state(params, (@transition_duration * 10).round)
  end
end
