class MapAnnotation
  # include BW::KVO

  attr_accessor :title,
                :subtitle,
                :animated,
                :point,
                :image,

                # A hash containing arbitrary user information
                :user_info,

                # Apple
                :identifier,
                :show_callout,
                :center_offset,
                :view_class,

                # Google
                :info_window_view,
                :info_contents_view

  def initialize(opts = {})
    @point = Point.new
    opts.each do |k,v|
      self.send("#{k}=",v)
    end
  end

  def coordinate
    point.asCLPoint
  end

  def setCoordinate(coordinate)
    willChangeValueForKey("coordinate")
    self.point.set(coordinate)
    didChangeValueForKey("coordinate")
  end

  def point=(point)
    @point.set(point)
  end

  def GMSMarker
    @GMSMarker ||= begin
      marker = GMSMarker.markerWithPosition(coordinate)
      marker.snippet = self.subtitle
      marker.title = self.title
      marker.appearAnimation = KGMSMarkerAnimationPop if self.animated
      marker.icon = self.image

      # observe(self, :coordinate) do |old_coordinate, new_coordinate|
      #   marker.position = new_coordinate.MKCoordinateValue
      # end

      marker
    end
  end

  def mapView=(mapView)
    self.GMSMarker.map = mapView
  end

end
