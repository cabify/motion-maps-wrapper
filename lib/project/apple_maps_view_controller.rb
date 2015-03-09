module AppleMapsViewController
  attr_accessor :annotations, :mapView, :enabled

  def viewDidLoad
    self.mapView = MKMapView.alloc.initWithFrame(self.view.frame)
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.mapView.delegate = self

    pan = UIPanGestureRecognizer.alloc.initWithTarget(self, action: 'handle_gesture_recognizer:')
    pan.delegate = self
    self.mapView.addGestureRecognizer(pan)

    self.view.addSubview(self.mapView)
  end

  #####################
  #### Annotations ####
  #####################

  def annotations
    @annotations ||= []
  end

  def add_annotation(annotation)
    self.annotations << annotation
    self.mapView.addAnnotation(annotation)
  end

  def add_annotations(annotations)
    self.annotations.concat(annotations)
    self.mapView.addAnnotations(annotations)
  end

  def remove_annotation(annotation)
    self.annotations.delete(annotation)
    self.mapView.removeAnnotation(annotation)
  end

  def remove_annotations(annotations)
    self.annotations = self.annotations - annotations
    self.mapView.removeAnnotations(annotations)
  end

  def clear_annotations
    self.mapView.removeAnnotations(self.annotations)
    self.annotations.clear
  end

  def selected_annotations
    # selectedAnnotations returns nil there are no annotations selected
    self.mapView.selectedAnnotations || []
  end

  def select_annotation(annotation, animated=true)
    self.mapView.selectAnnotation(annotation, animated:animated)
  end

  def deselect_annotation(annotation, animated=true)
    self.mapView.deselectAnnotation(annotation, animated:animated)
  end

  def zoom_to_fit_annotations(opts = {})
    points = self.annotations.map(&:coordinates)
    region = Point.map_region_for(points)
    self.region(region, opts)
  end

  def mapView(mapView, viewForAnnotation:annotation)
    if annotation.is_a?(MKUserLocation)
      annotation.title = nil
      return nil # Use default location icon
    end

    identifier = annotation.identifier
    if view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
      view.annotation = annotation
    else

      view = MKAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)

      if annotation.image
        annotation_class = annotation.view_class || MKAnnotationView
        view = annotation_class.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)
        view.image = annotation.image
      else
        view = MKPinAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)
        view.animatesDrop = annotation.animated
        view.pinColor = annotation.pin_color if annotation.pin_color
      end

      view.canShowCallout = annotation.show_callout
      view.centerOffset = annotation.center_offset if annotation.center_offset
    end
    view
  end

  ##################
  #### Position ####
  ##################

  def center(center=nil, opts = {})
    if center.nil?
      return Point.new(self.mapView.centerCoordinate)
    end

    center = Point.new(center)
    self.mapView.setCenterCoordinate(center.asCLPoint, animated:opts[:animated])
  end

  def region(region=nil, opts = {})
    if region.nil?
      return Region.new(self.mapView.region)
    end

    if !region.is_a?(MKCoordinateRegion)
      region = region.asMKCoordinateRegion
    end
    self.mapView.setRegion(region, animated: opts[:animated])
  end

  ##################
  #### Tracking ####
  ##################

  def show_user_location(show_location)
    self.mapView.showsUserLocation = show_location
  end

  # @param [Hash] opts
  # @option opts [Boolean] :animated true if the movement is animated
  # @option opts [Boolean] :gesture true if the movement was originated by user interaction
  def map_will_move(opts = {})
    # puts "map_will_move #{opts}"
  end

  # NOTE: For MKMapView, this is only called when the map is moving because of a gesture recognizer, not an animated change.
  # @param [Hash] opts
  # @option opts [Boolean] :animated true if the movement is animated
  # @option opts [Boolean] :gesture true if the movement was originated by user interaction
  # @option opts [Point] :position the center position of the map after the movement finishes
  def map_is_moving(opts = {})
    # puts "map_is_moving #{opts}"
  end

  # @param [Hash] opts
  # @option opts [Boolean] :animated true if the movement is animated
  # @option opts [Boolean] :gesture ttrue if the movement was originated by user interaction
  # @option opts [Point] :position the center position of the map after the movement finishes
  def map_did_move(opts = {})
    # puts "map_did_move #{opts}"
  end

  # Called repeatedly during any animations or gestures on the map (or once, if the camera is explicitly set)
  def mapView(mapView, regionWillChangeAnimated:animated)
    @_map_moving_with_gesture = mapViewRegionDidChangeFromUserInteraction
    map_will_move animated: animated,
                  gesture: @_map_moving_with_gesture
  end

  def mapView(mapView, regionDidChangeAnimated:animated)
    map_did_move animated: animated,
                 gesture:  @_map_moving_with_gesture,
                 position: center
    @_map_moving_with_gesture = false
  end

  ##################
  #### Gestures ####
  ##################

  def handle_gesture_recognizer(gesture_recognizer)
    case gesture_recognizer.state
    when UIGestureRecognizerStateBegan
    when UIGestureRecognizerStateChanged
      map_is_moving animated: false,
                    gesture:  true,
                    position: center
    end
  end

  def gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer: otherGestureRecognizer)
    true
  end

  def mapViewRegionDidChangeFromUserInteraction
    view = self.mapView.subviews.first
    #  Look through gesture recognizers to determine whether this region change is from user interaction
    view.gestureRecognizers.each do |recognizer|
      return true if recognizer.state == UIGestureRecognizerStateBegan
    end
    false
  end

  ###############
  #### Utils ####
  ###############

  def enabled(enabled)
    return enabled if @enabled == enabled

    mapView.zoomEnabled = enabled
    mapView.scrollEnabled = enabled
    mapView.userInteractionEnabled = enabled

    @enabled = enabled
  end

  def enable_map
    self.enabled(true)
  end

  def disable_map
    self.enabled(false)
  end

  def maps_logo_view
    mapView.subviews.find{|v| v.is_a?(UILabel)}
  end

end
