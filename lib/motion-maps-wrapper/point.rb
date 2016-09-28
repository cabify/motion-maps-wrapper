class Point

  attr_accessor :latitude, :longitude

  def self.new(point = [0,0])
    return point if point.is_a?(Point)
    super
  end

  def initialize(point = [0,0])
    set(point)
    self
  end

  def set(point)
    if point.is_a?(MKUserLocation)
      point = point.location.coordinate if point.location
    end

    if point.is_a?(CLLocation)
      point = point.coordinate
    end

    case point
    when Point, CLLocationCoordinate2D
      @latitude  = point.latitude.to_f
      @longitude = point.longitude.to_f
    when Array
      @latitude  = point[0].to_f
      @longitude = point[1].to_f
    end
  end

  # TODO: This is wrong, MKMapPoint cant use degree values
  def asMapPoint
    # MKMapPointForCoordinate(self.asCLPoint)
    MKMapPointMake(@latitude, @longitude)
  end

  def asCLPoint
    CLLocationCoordinate2DMake(@latitude, @longitude)
  end

  def asCLLocation
    CLLocation.alloc.initWithLatitude(@latitude, longitude: @longitude)
  end

  def as_json
    [@latitude, @longitude]
  end

  def to_a
    [@latitude, @longitude]
  end

  def to_s
    "#{@latitude},#{@longitude}"
  end

  def to_param
    "#{@latitude},#{@longitude}"
  end

  def valid?
    (@latitude && @latitude != 0.0) && (@longitude && @longitude != 0.0)
  end

  def ==(other)
    if [Point, CLLocationCoordinate2D, MKUserLocation, CLLocation].include?(other.class)
      other = Point.new(other)
      ((@latitude - other.latitude).abs < 0.005) && ((@longitude - other.longitude).abs < 0.005)
    else
      super
    end
  end
  alias :eql? :==
  alias :equals? :==

  # TODO: This is using MKMapPoint with degree values, that's wrong
  def inside?(zone)
    inPoly = false
    if zone == nil || zone.count == 0
        return false
    end

    lastPointData = Point.new(zone[zone.size-1])
    lastPoint = lastPointData.asMapPoint
    here = self.asMapPoint

    zone.each do |point|
      point = Point.new(point).asMapPoint

      if (((point.y < here.y) && (lastPoint.y >= here.y)) || ((lastPoint.y < here.y) && (point.y >= here.y)))
          if ((point.x + (((here.y - point.y) / (lastPoint.y - point.y)) * (lastPoint.x - point.x))) < here.x)
              inPoly = !inPoly
          end
      end
      lastPoint = point
    end

    inPoly
  end

  def distance_from(point)
    self.asCLLocation.distanceFromLocation(point.asCLLocation)
  end

  def human_distance_from(point)
    return unless point.is_a?(Point)

    distance = distance_from(point)

    if distance > 999
      # Use a formatter
      formatter = NSNumberFormatter.alloc.init
      formatter.setLocale(NSLocale.currentLocale)
      formatter.setMaximumFractionDigits(1)
      formatter.stringFromNumber(distance.to_f / 1000) + "km"
    elsif distance > 50
      # Use 10s
      "%dm" % ((distance / 10).to_i * 10)
    else
      # Basic integer
      "%dm" % distance
    end
  end

end
