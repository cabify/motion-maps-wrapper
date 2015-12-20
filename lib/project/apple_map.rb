class AppleMap

  attr_accessor :annotations, :view, :enabled, :delegate

  def initialize
    self.view = MKMapView.alloc.initWithFrame(CGRectZero)
    self.view.delegate = self

    pan = UIPanGestureRecognizer.alloc.initWithTarget(self, action: 'handle_gesture_recognizer:')
    pan.delegate = self
    self.view.addGestureRecognizer(pan)

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
    self.annotations << annotation
    self.view.addAnnotation(annotation)
  end

  def add_annotations(annotations)
    self.annotations.concat(annotations)
    self.view.addAnnotations(annotations)
  end

  def remove_annotation(annotation)
    self.annotations.delete(annotation)
    self.view.removeAnnotation(annotation)
  end

  def remove_annotations(annotations)
    self.annotations = self.annotations - annotations
    self.view.removeAnnotations(annotations)
  end

  def clear_annotations
    self.view.removeAnnotations(self.annotations)
    self.annotations.clear
  end

  def selected_annotations
    # selectedAnnotations returns nil there are no annotations selected
    self.view.selectedAnnotations || []
  end

  def select_annotation(annotation, animated=true)
    self.view.selectAnnotation(annotation, animated:animated)
  end

  def deselect_annotation(annotation, animated=true)
    self.view.deselectAnnotation(annotation, animated:animated)
  end

  def zoom_to_fit_annotations(opts = {})
    points = self.annotations.map(&:coordinates)
    region = Point.map_region_for(points)
    self.region(region, opts)
  end

  def mapView(map_view, viewForAnnotation:annotation)
    if annotation.is_a?(MKUserLocation)
      annotation.title = nil
      return nil # Use default location icon
    end

    identifier = annotation.identifier
    if annotation.annotation_view
      annotation_view = annotation.annotation_view
    elsif annotation_view = view.dequeueReusableAnnotationViewWithIdentifier(identifier)
      annotation_view.annotation = annotation
    else

      annotation_view = MKAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)

      if annotation.image
        annotation_class = annotation.view_class || MKAnnotationView
        annotation_view = annotation_class.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)
        annotation_view.image = annotation.image
      else
        annotation_view = MKPinAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)
        annotation_view.animatesDrop = annotation.animated
        annotation_view.pinColor = annotation.pin_color if annotation.pin_color
      end

      annotation_view.canShowCallout = annotation.show_callout
      annotation_view.centerOffset = annotation.center_offset if annotation.center_offset

      annotation_view.subview(annotation.info_window_view) if annotation.info_window_view
    end
    annotation_view
  end

  def mapView(mapView, didDeselectAnnotationView:annotation_view)
    if delegate && delegate.respond_to?('did_deselect_annotation')
      delegate.did_deselect_annotation(annotation_view.annotation)
    end
  end

  def mapView(mapView, didSelectAnnotationView:annotation_view)
    if delegate && delegate.respond_to?('did_select_annotation')
      delegate.did_select_annotation(annotation_view.annotation)
    end
  end

  ##################
  #### Position ####
  ##################

  def center(center=nil, opts = {})
    if center.nil?
      return Point.new(self.view.centerCoordinate)
    end

    center = Point.new(center)
    self.view.setCenterCoordinate(center.asCLPoint, animated:opts[:animated])
  end

  def region(region=nil, opts = {})
    if region.nil?
      return Region.new(self.view.region)
    end

    if !region.is_a?(MKCoordinateRegion)
      region = region.asMKCoordinateRegion
    end

    if opts[:insets]
      # Convert MKCoordinateRegion to MKMapRect
      a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
          region.center.latitude + region.span.latitudeDelta / 2,
          region.center.longitude - region.span.longitudeDelta / 2))
      b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
          region.center.latitude - region.span.latitudeDelta / 2,
          region.center.longitude + region.span.longitudeDelta / 2))
      map_rect = MKMapRectMake([a.x,b.x].min, [a.y,b.y].min, (a.x-b.x).abs, (a.y-b.y).abs)
      self.view.setVisibleMapRect(map_rect, edgePadding: UIEdgeInsetsMake(*opts[:insets]), animated:opts[:animated])
    else
      self.view.setRegion(region, animated: opts[:animated])
    end
  end

  ##################
  #### Tracking ####
  ##################

  def show_user_location(show_location)
    self.view.showsUserLocation = show_location
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
  def mapView(map_view, regionWillChangeAnimated:animated)
    @_map_moving_with_gesture = mapViewRegionDidChangeFromUserInteraction
    if delegate && delegate.respond_to?('map_will_move')
      delegate.map_will_move animated: animated,
                             gesture: @_map_moving_with_gesture
    end
  end

  def mapView(map_view, regionDidChangeAnimated:animated)
    if delegate && delegate.respond_to?('map_did_move')
      delegate.map_did_move animated: animated,
                            gesture:  @_map_moving_with_gesture,
                            position: center
    end
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
    view = self.view.subviews.first
    #  Look through gesture recognizers to determine whether this region change is from user interaction
    view.gestureRecognizers.each do |recognizer|
      return true if recognizer.state == UIGestureRecognizerStateBegan
    end
    false
  end

  ###############
  #### Utils ####
  ###############

  def enabled=(enabled)
    return enabled if @enabled == enabled

    view.zoomEnabled = enabled
    view.scrollEnabled = enabled
    view.userInteractionEnabled = enabled

    @enabled = enabled
  end

  def enable_map
    self.enabled = true
  end

  def disable_map
    self.enabled = false
  end

  def maps_logo_view
    view.subviews.find{|v| v.is_a?(UILabel)}
  end

end
