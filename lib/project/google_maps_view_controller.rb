class GoogleMapsViewController < UIViewController

  attr_accessor :annotations, :mapView

  def init
    super
    self.title = "Google"
    self.annotations = []
    self
  end

  def loadView
    camera = GMSCameraPosition.cameraWithLatitude(-33.868, longitude:151.2086, zoom:6)
    self.mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
    self.view = self.mapView
  end

  #####################
  #### Annotations ####
  #####################

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

  def center
    Point.new(self.mapView.camera.target)
  end

  def center=(center, opts = {})
    point = Point.new(center).asCLPoint
    camera_update = GMSCameraUpdate.setTarget(point)
    if opts[:animated]
      self.mapView.animateWithCameraUpdate(camera_update)
    else
      self.mapView.moveCamera(camera_update)
    end
  end

  def region
    Region.new(self.mapView.projection.visibleRegion)
  end

  def region=(region, opts = {})
    region = Region.new(region)

    opts[:insets] ||= [0,0,0,0]
    insets = UIEdgeInsetsMake(*opts[:insets])
    camera = self.mapView.cameraForBounds(region.asGMSCoordinateBounds, insets:insets)

    if opts[:animated]
      self.mapView.animateToCameraPosition(camera)
    else
      self.mapView.camera = camera
    end
  end

  ##################
  #### Tracking ####
  ##################

  def show_user_location(show_location)
    self.mapView.myLocationEnabled = show_location
  end

  ###############
  #### Utils ####
  ###############

end
