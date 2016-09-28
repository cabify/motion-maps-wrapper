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
                :tappable,
                :zIndex,
                :iconView,
                :marker

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
    self.marker.position = point.asCLPoint if @marker
    didChangeValueForKey("coordinate")
  end

  def point=(point)
    self.point.set(point)
    setCoordinate(point) if @marker
    self.point
  end

  def marker
    @marker ||=
      begin
        _marker = GMSMarker.markerWithPosition(coordinate)
        _marker.snippet = self.subtitle
        _marker.title = self.title
        _marker.appearAnimation = KGMSMarkerAnimationPop if self.animated
        _marker.icon = self.image
        _marker.position = point.asCLPoint
        _marker.zIndex = self.zIndex if self.zIndex
        _marker.iconView = self.iconView if self.iconView
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
    self.marker.icon = image if @marker
    @image = image
  end

  def zIndex=(zIndex)
    @zIndex = zIndex
    self.marker.zIndex = zIndex if @marker
    self.zIndex
  end

  def iconView=(iconView)
    @iconView = iconView
    self.marker.iconView = iconView if @marker
    self.iconView
  end

  # Google maps only
  def mapView=(mapView)
    self.marker.map = mapView
  end

end
