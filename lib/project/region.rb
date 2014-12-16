class Region

  attr_accessor :points,
                :center,
                :span,
                :lat_factor,
                :lon_factor,
                :center_factor

  def self.new(region = {})
    return region if region.is_a?(Region)
    super
  end

  def initialize(region = {})
    if region.is_a?(MKCoordinateRegion)
      self.center = Point.new(region.center)
      self.span = [
        region.span.latitudeDelta,
        region.span.longitudeDelta
      ]
    elsif region.is_a?(GMSCoordinateBounds)
      self.points = [
        Point.new(region.northEast),
        Point.new(region.southWest)
      ]
    elsif region.is_a?(GMSVisibleRegion)
      self.points = [
        Point.new(region.farRight),
        Point.new(region.nearLeft)
      ]
    else
      self.points = region[:points].map { |p| Point.new(p) } if region[:points]
      self.center = Point.new(region[:center]) if region[:center]
      self.span = region[:span]
      self.center_factor = region[:center_factor]
      self.lat_factor = region[:lat_factor]
      self.lon_factor = region[:lon_factor]
    end
  end

  def center_factor
    @center_factor || 1.0
  end

  def lat_factor
    @lat_factor || 1.0
  end

  def lon_factor
    @lon_factor || 1.0
  end

  def span
    @span || [0.005, 0.0065]
  end

  def as_bounds
    if center && span
      nec = Point.new # NorthEastCorner
      swc = Point.new # SouthWestCorner
      nec.latitude  = center.latitude  + (span[0] / 2.0)
      nec.longitude = center.longitude + (span[1] / 2.0)
      swc.latitude  = center.latitude  - (span[0]  / 2.0)
      swc.longitude = center.longitude - (span[1] / 2.0)
      [nec, swc]
    elsif points && points.length == 1
      # If there is only one point, we show it with some span
      point = points.first
      nec = Point.new # NorthEastCorner
      swc = Point.new # SouthWestCorner
      nec.latitude  = point.latitude  + (span[0] / 2.0)
      nec.longitude = point.longitude + (span[1] / 2.0)
      swc.latitude  = point.latitude  - (span[0]  / 2.0)
      swc.longitude = point.longitude - (span[1] / 2.0)
      [nec, swc]
    elsif points
      maxLat = points.max_by { |a| a.latitude }.latitude
      minLat = points.min_by { |a| a.latitude }.latitude
      maxLon = points.max_by { |a| a.longitude }.longitude
      minLon = points.min_by { |a| a.longitude }.longitude

      deltaLat = (maxLat - minLat)
      deltaLon = (maxLon - minLon)

      # Correct the center latitude
      latitude_correction = ((deltaLat * lat_factor * center_factor) - deltaLat * lat_factor)

      # Span to add to latitude and longitude
      spanLat = (deltaLat * lat_factor - deltaLat) / 2
      spanLon = (deltaLon * lon_factor - deltaLon) / 2

      # Calculate the final coordinates
      maxLat = (maxLat + spanLat) + latitude_correction
      minLat = (minLat - spanLat) + latitude_correction
      maxLon = maxLon + spanLon
      minLon = minLon - spanLon

      [Point.new([maxLat, maxLon]), Point.new([minLat, minLon])]
    end
  end

  def as_center_and_span
    if center && span
      [center, span]
    elsif points && points.length == 1
      [points.first, span]
    elsif points
      list = points.compact.reject{|a| !a.valid?}

      maxLat = list.max_by { |a| a.latitude }.latitude
      minLat = list.min_by { |a| a.latitude }.latitude
      maxLon = list.max_by { |a| a.longitude }.longitude
      minLon = list.min_by { |a| a.longitude }.longitude

      latDelta = (maxLat - minLat) * lat_factor
      lonDelta = (maxLon - minLon) * lon_factor

      # Do we need to correct the center position?
      latCor = (latDelta * center_factor) - latDelta

      #puts "LAT COR: #{latCor} FOR DELTA: #{latDelta} MAX: #{maxLat} MIN: #{minLat}"
      center_lat = ((maxLat + minLat) / 2.0) + latCor
      center_lon = (minLon + maxLon) / 2.0

      span   = [latDelta, lonDelta]

      [Point.new([center_lat, center_lon]), span]
    end
  end

  def asMKCoordinateRegion
    center, span = self.as_center_and_span
    coordinate_span = MKCoordinateSpanMake(span[0], span[1])
    MKCoordinateRegionMake(center.asCLPoint, span)
  end

  def asGMSCoordinateBounds
    bounds = self.as_bounds
    GMSCoordinateBounds.alloc.initWithCoordinate(bounds[0].asCLPoint, coordinate: bounds[1].asCLPoint)
  end

  def ==(region)
    if [Region, MKCoordinateRegion, GMSCoordinateBounds, GMSVisibleRegion].include?(region.class)
      region = Region.new(region)
      self.as_bounds == region.as_bounds
    else
      super
    end
  end
  alias :eql? :==
  alias :equals? :==

end
