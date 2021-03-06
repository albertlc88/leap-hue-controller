require 'matrix'
require 'leap-motion-ws'
require_relative 'lighter'

class Listener < LEAP::Motion::WS
  def initialize(lighter:)
    super()
    @lighter = lighter
  end

  def on_frame(frame)
    return if @lighter.transiting
    unless hand = frame.hands.first
      return
    end

    x, y, _ = hand.palmNormal
    x = -x if x > 0
    acos = Math.acos(x)
    angle = y >= 0 ? acos : 2 * Math::PI - acos # 1/2pi - 3/2pi
    hue = (((angle / Math::PI) - 0.5) * Lighter::MAX_HUE).round

    hand_id = hand.id
    fingers = frame.pointables.select {|pointable| pointable.handId == hand_id}
    saturation = (255 / 5) * fingers.length

    bri_ratio = (Vector[*hand.palmPosition].norm / 400) # TODO: 400 is a magic number. Consider interaction box.
    bri_ratio = 1.0 if bri_ratio > 1
    brightness = (255 * bri_ratio).round

    @lighter.light hue: hue, saturation: saturation, brightness: brightness
  end
end
