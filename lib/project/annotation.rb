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
                :ground_anchor

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
      if self.image_url
        url = NSURL.URLWithString(image_url)
        SDWebImageManager.sharedManager.downloadWithURL(url, options:SDWebImageRetryFailed,
          progress:nil, completed: proc do |image, error, cached, finished|
            marker.icon = image if finished
          end)
      else
        marker.icon = self.image
      end
      marker.infoWindowAnchor = self.info_window_anchor if self.info_window_anchor
      marker.groundAnchor = self.ground_anchor if self.ground_anchor
      marker
    end
  end

  def mapView=(mapView)
    self.GMSMarker.map = mapView
  end

end
