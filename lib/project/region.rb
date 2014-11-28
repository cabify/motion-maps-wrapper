class Region

  attr_accessor :points,
                :center,
                :span

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
      self.span = region[:span] if region[:span]
    end
  end

  def as_bounds
    if span && center
      nec = Point.new # NorthEastCorner
      swc = Point.new # SouthWestCorner
      nec.latitude  = center.latitude  + (span[0] / 2.0)
      nec.longitude = center.longitude + (span[1] / 2.0)
      swc.latitude  = center.latitude  - (span[0]  / 2.0)
      swc.longitude = center.longitude - (span[1] / 2.0)
      [nec, swc]
    elsif points
      maxLat = points.max_by { |a| a.latitude }.latitude
      minLat = points.min_by { |a| a.latitude }.latitude
      maxLon = points.max_by { |a| a.longitude }.longitude
      minLon = points.min_by { |a| a.longitude }.longitude
      [Point.new([maxLat, maxLon]), Point.new([minLat, minLon])]
    end
  end

  def asMKCoordinateRegion
    if center && span
      span = MKCoordinateSpanMake(span[0], span[1])
      MKCoordinateRegionMake(center.asCLLocation, span)
    elsif points
      Point.map_region_for(points)
    end
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
