class GoogleMap

  attr_accessor :annotations, :view, :enabled, :delegate

  def initialize
    self.view = GMSMapView.mapWithFrame(CGRectZero, camera:nil)
    self.view.delegate = self
    self
  end

  def delegate=(delegate)
    @delegate = WeakRef.new(delegate)
  end

  #####################
  #### Annotations ####
  #####################

  def annotations
    @annotations ||= []
  end

  def add_annotation(annotation)
    annotation.mapView = self.view
    self.annotations << annotation
    annotation
  end

  def add_annotations(annotations)
    annotations.each do |annotation|
      add_annotation(annotation)
    end
  end

  def remove_annotation(annotation)
    annotation.mapView = nil
    self.annotations.delete(annotation)
  end

  def remove_annotations(annotations)
    annotations.each do |annotation|
      remove_annotation(annotation)
    end
  end

  def clear_annotations
    self.annotations.clear
    self.view.clear
  end

  def selected_annotations
    # Google maps can only have one marker selected at the same time
    [self.annotations.find { |a| a.GMSMarker == self.view.selectedMarker }].compact
  end

  def select_annotation(annotation)
    self.view.selectedMarker = annotation.GMSMarker
  end

  def deselect_annotation(annotation)
    self.view.selectedMarker = nil
  end

  def zoom_to_fit_annotations(opts = {})
    points = self.annotations.map(&:coordinates)
    region = Point.map_region_for(points)
    self.region(region, opts)
  end

  def mapView(mapView, markerInfoWindow:marker)
    annotation = self.annotations.find { |a| a.GMSMarker == marker }
    annotation.info_window_view if annotation.respond_to?("info_window_view")
  end

  def mapView(mapView, markerInfoContents:marker)
    marker.info_contents_view if marker.respond_to?("info_contents_view")
  end

  ##################
  #### Position ####
  ##################

  def center(center=nil, opts = {})
    if center.nil?
      camera = self.view.camera
      return (camera ? Point.new(camera.target) : nil)
    end

    point = Point.new(center).asCLPoint
    camera_update = GMSCameraUpdate.setTarget(point)
    if opts[:animated]
      @_map_moving_animated = true
      self.view.animateWithCameraUpdate(camera_update)
    else
      @_map_moving_animated = false
      self.view.moveCamera(camera_update)
    end
  end

  def region(region=nil, opts = {})
    if region.nil?
      return Region.new(self.view.projection.visibleRegion)
    end

    region = Region.new(region)

    opts[:insets] ||= [0,0,0,0]
    insets = UIEdgeInsetsMake(*opts[:insets])
    camera = self.view.cameraForBounds(region.asGMSCoordinateBounds, insets:insets)

    if opts[:animated]
      @_map_moving_animated = true
      self.view.animateToCameraPosition(camera)
    else
      @_map_moving_animated = false
      self.view.camera = camera
    end
  end

  ##################
  #### Tracking ####
  ##################

  def show_user_location(show_location)
    self.view.myLocationEnabled = show_location
  end

  # @param [Hash] opts
  # @option opts [Boolean] :animated true if the movement is animated
  # @option opts [Boolean] :gesture true if the movement was originated by user interaction
  def map_will_move(opts = {})
    # puts "map_will_move #{opts}"
  end

  # @param [Hash] opts
  # @option opts [Boolean] :animated true if the movement is animated
  # @option opts [Boolean] :gesture true if the movement was originated by user interaction
  # @option opts [Point] :position the center position of the map after the movement finishes
  def map_is_moving(opts = {})
    # puts "map_is_moving #{opts}"
  end

  # @param [Hash] opts
  # @option opts [Boolean] :animated true if the movement is animated
  # @option opts [Boolean] :gesture true if the movement was originated by user interaction
  # @option opts [Point] :position the center position of the map after the movement finishes
  def map_did_move(opts = {})
    # puts "map_did_move #{opts}"
  end

  # Called before the camera on the map changes, either due to a gesture, animation or by being updated explicitly via the camera
  def mapView(mapView, willMove:isGesture)
    @_map_moving_with_gesture = isGesture
    if delegate && delegate.respond_to?('map_will_move')
      delegate.map_will_move animated: @_map_moving_animated || false,
                             gesture:  isGesture
    end
  end

  # Called repeatedly during any animations or gestures on the map (or once, if the camera is explicitly set).
  # This may not be called for all intermediate camera positions. It is always called for the final position of an animation or gesture.
  def mapView(mapView, didChangeCameraPosition:position)
    if delegate && delegate.respond_to?('map_is_moving')
      delegate.map_is_moving animated: @_map_moving_animated || false,
                             gesture:  @_map_moving_with_gesture || false,
                             position: Point.new(position.target)
    end
  end

  # Called when the map becomes idle, after any outstanding gestures or animations have completed (or after the camera has been explicitly set).
  def mapView(mapView, idleAtCameraPosition:position)
    if delegate && delegate.respond_to?('map_did_move')
      delegate.map_did_move animated: @_map_moving_animated || false,
                            gesture:  @_map_moving_with_gesture || false,
                            position: Point.new(position.target)
    end
    @_map_moving_animated = false
  end

  ###############
  #### Utils ####
  ###############

  def enabled=(enabled)
    return enabled if @enabled == enabled

    view.settings.allGesturesEnabled = enabled

    @enabled = enabled
  end

  def enable_map
    self.enabled = true
  end

  def disable_map
    self.enabled = false
  end

  def maps_logo_view
    settings_view = self.view.subviews.find { |v| v.is_a?(GMSUISettingsView) }
    return nil if !settings_view
    settings_view.subviews.find { |v| v.is_a?(UIButton) && v.accessibilityLabel == "Google Maps" }
  end

end
