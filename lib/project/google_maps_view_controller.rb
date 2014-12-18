# class GoogleMapsViewController < ProMotion::ViewController
class GoogleMapsViewController < UIViewController

  attr_accessor :annotations, :mapView

  def viewDidLoad
    self.mapView = GMSMapView.mapWithFrame(self.view.frame, camera:nil)
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.mapView.delegate = self
    self.view.addSubview(self.mapView)
  end

  #####################
  #### Annotations ####
  #####################

  def annotations
    @annotations ||= []
  end

  def add_annotation(annotation)
    annotation.mapView = self.mapView
    self.annotations << annotation
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
    self.mapView.clear
  end

  def selected_annotations
    # Google maps can only have one marker selected at the same time
    [self.annotations.find { |a| a.GMSMarker == self.mapView.selectedMarker }].compact
  end

  def select_annotation(annotation)
    self.mapView.selectedMarker = annotation.GMSMarker
  end

  def deselect_annotation(annotation)
    self.mapView.selectedMarker = nil
  end

  def zoom_to_fit_annotations(opts = {})
    points = self.annotations.map(&:coordinates)
    region = Point.map_region_for(points)
    self.region(region, opts)
  end

  def mapView(mapView, markerInfoWindow:marker)
    marker.info_window_view if marker.respond_to?("info_window_view")
  end

  def mapView(mapView, markerInfoContents:marker)
    marker.info_contents_view if marker.respond_to?("info_contents_view")
  end

  ##################
  #### Position ####
  ##################

  def center(center=nil, opts = {})
    if center.nil?
      camera = self.mapView.camera
      return (camera ? Point.new(camera.target) : nil)
    end

    point = Point.new(center).asCLPoint
    camera_update = GMSCameraUpdate.setTarget(point)
    if opts[:animated]
      @_map_moving_animated = true
      self.mapView.animateWithCameraUpdate(camera_update)
    else
      @_map_moving_animated = false
      self.mapView.moveCamera(camera_update)
    end
  end

  def region(region=nil, opts = {})
    if region.nil?
      return Region.new(self.mapView.projection.visibleRegion)
    end

    region = Region.new(region)

    opts[:insets] ||= [0,0,0,0]
    insets = UIEdgeInsetsMake(*opts[:insets])
    camera = self.mapView.cameraForBounds(region.asGMSCoordinateBounds, insets:insets)

    if opts[:animated]
      @_map_moving_animated = true
      self.mapView.animateToCameraPosition(camera)
    else
      @_map_moving_animated = false
      self.mapView.camera = camera
    end
  end

  ##################
  #### Tracking ####
  ##################

  def show_user_location(show_location)
    self.mapView.myLocationEnabled = show_location
  end

  # @param [Hash] opts
  # @option opts [Boolean] :animated true if the movement is animated
  # @option opts [Boolean] :gesture true if the movement was originated by user interaction
  def map_will_move(opts = {})
  end

  # @param [Hash] opts
  # @option opts [Boolean] :animated true if the movement is animated
  # @option opts [Boolean] :gesture ttrue if the movement was originated by user interaction
  # @option opts [Point] :position the center position of the map after the movement finishes
  def map_did_move(opts = {})
  end

  # Called before the camera on the map changes, either due to a gesture, animation or by being updated explicitly via the camera
  def mapView(mapView, willMove:isGesture)
    # puts "willMove: isGesture:#{isGesture}"
    @_map_moving_with_gesture = isGesture
    map_will_move animated: @_map_moving_animated || false,
                  gesture:  isGesture
  end

  # Called when the map becomes idle, after any outstanding gestures or animations have completed (or after the camera has been explicitly set).
  def mapView(mapView, idleAtCameraPosition:position)
    # puts "idleAtCameraPosition"
    map_did_move animated: @_map_moving_animated || false,
                 gesture:  @_map_moving_with_gesture || false,
                 position: Point.new(position.target)
    @_map_moving_animated = false
  end

  ###############
  #### Utils ####
  ###############

  def enabled(enabled)
    return enabled if @enabled == enabled

    mapView.userInteractionEnabled = enabled

    @enabled = enabled
  end

  def enable_map
    self.enabled(true)
  end

  def disable_map
    self.enabled(false)
  end
end
