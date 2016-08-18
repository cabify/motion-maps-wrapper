class MapAnnotation
  attr_accessor :title,
                :subtitle,
                :animated,
                :point,
                :image,
                :image_url,

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
                :info_contents_view,
                :info_window_anchor,
                :ground_anchor,
                :tappable

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
    marker.position = point.asCLPoint if @GMSMarker
    didChangeValueForKey("coordinate")
  end

  def point=(point)
    self.point.set(point)
    self.point
  end

  def marker
    @GMSMarker ||= begin
      _marker = GMSMarker.markerWithPosition(coordinate)
      _marker.snippet = self.subtitle
      _marker.title = self.title
      _marker.appearAnimation = KGMSMarkerAnimationPop if self.animated
      _marker.icon = self.image
      _marker.position = point.asCLPoint
      if self.image_url
        url = NSURL.URLWithString(image_url)
        SDWebImageManager.sharedManager.downloadWithURL(url, options:SDWebImageRetryFailed,
          progress:nil, completed: proc do |image, error, cached, finished|
            _marker.icon = image if finished
          end)
      end
      _marker.infoWindowAnchor = self.info_window_anchor if self.info_window_anchor
      _marker.groundAnchor = self.ground_anchor if self.ground_anchor
      _marker.tappable = self.tappable.nil? ? true : self.tappable
      _marker
    end
  end

  def image=(image)
    marker.icon = image if @GMSMarker
    @image = image
  end

  def mapView=(mapView)
    marker.map = mapView
  end

end
