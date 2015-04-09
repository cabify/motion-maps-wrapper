class MapAnnotation
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
                :pin_color,
                :annotation_view,

                # Google
                :info_window_view,
                :info_contents_view

  def initialize(opts = {})
    @point = Point.new
    set(opts)
  end

  def set(opts)
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
    @GMSMarker.position = coordinate if @GMSMarker
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
      marker
    end
  end

  def mapView=(mapView)
    self.GMSMarker.map = mapView
  end

end
