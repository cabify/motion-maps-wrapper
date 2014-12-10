class AbstractMapsViewController < UIViewController

  attr_accessor :annotations, :mapView

  def init
    super
    self.title = "Abstract"
    self.annotations = []
    self
  end

  #####################
  #### Annotations ####
  #####################

  def add_annotation(annotation)
  end

  def add_annotations(annotations)
  end

  def remove_annotation(annotation)
  end

  def remove_annotations(annotations)
  end

  def clear_annotations
  end

  def selected_annotations
  end

  def select_annotation(annotation, animated=true)
  end

  def deselect_annotation(annotation, animated=true)
  end

  def zoom_to_fit_annotations(opts = {})
  end

  # Apple
  def mapView(mapView, viewForAnnotation:annotation)
  end

  # Google
  def mapView(mapView, markerInfoWindow:marker)
  end

  def mapView(mapView, markerInfoContents:marker)
  end

  ##################
  #### Position ####
  ##################

  # Returns the map coordinate at the center of the map view
  def center
  end

  # Moves the center coordinate of the map
  # @param point [Array, CLLocationCoordinate2D, Point]
  # @param opts [Hash]
  # @option opts [Boolean] Determines if the change is animated
  def center=(point, opts = {})
  end

  # The area currently displayed by the map view.
  def region
  end

  # Changes the currently visible region
  # @param region [Array, Region, MKCoordinateRegion]
  # @param opts [Hash]
  # @option opts [Boolean] :animated Determines if the change is animated
  # @option opts [Array] :span Detemines the span of the region
  def region=(region, opts = {})
  end

  ##################
  #### Tracking ####
  ##################

  def show_user_location(show_location)
  end

  ###############
  #### Utils ####
  ###############

  def enabled=(enabled)
  end

  def enable_map
  end

  def disable_map
  end
end
