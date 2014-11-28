describe "Region" do

  before do
    @span = MKCoordinateSpanMake(0.030833, 0.045319)
    @coordinate_region = MKCoordinateRegionMake(Point.new([40.4406995, -3.6939565]).asCLPoint, @span)

    north_east = Point.new([40.456116, -3.671297]).asCLPoint
    south_west = Point.new([40.425283, -3.716616]).asCLPoint
    @coordinate_bounds = GMSCoordinateBounds.alloc.initWithCoordinate(north_east, coordinate:south_west)

    # This region is equivalent to the previous two
    @region1 = Region.new(points:[[40.456116, -3.671297], [40.425283, -3.716616]])
    # This region has some values changed from the previous one
    @region2 = Region.new(points:[[40.457116, -3.671597], [40.425293, -3.746616]])
  end

  describe "initialization" do
    it "can be initialized with MKCoordinateRegion" do
      region = Region.new(@coordinate_region)

      region.center.should == Point.new(@coordinate_region.center)
      region.span[0].should == @span.latitudeDelta
      region.span[1].should == @span.longitudeDelta
    end

    it "can be initialized with GMSGoordinateBounds" do
      region = Region.new(@coordinate_bounds)
      bounds = region.as_bounds
      bounds[0].should == Point.new(@coordinate_bounds.northEast)
      bounds[1].should == Point.new(@coordinate_bounds.southWest)
    end

    it "can be initialized with an array of points" do
      point1 = [40.456116, -3.671297]
      point2 = [40.425283, -3.716616]
      region = Region.new(points:[point1, point2])
      region.points.include?(Point.new(point1)).should == true
      region.points.include?(Point.new(point2)).should == true
    end

    it "can be initialized with a center and span" do
      center = [40.425283, -3.716616]
      span = [0.01, 0.01]
      region = Region.new(center: center, span: span)
      region.center.should == Point.new(center)
      region.span[0].should == span[0]
      region.span[1].should == span[1]
    end

    it "can be initialized with another region" do
      region1 = Region.new(points:[[40.457116, -3.671597], [40.425293, -3.746616]])
      region2 = Region.new(region1)
      region1.__id__.should == region2.__id__
    end

    it "can be initialized with a GMSVisibleRegion" do
      visible_region = GMSVisibleRegion.new
      visible_region.nearLeft = Point.new([40.0, -3.0]).asCLPoint
      visible_region.nearRight = Point.new([41.0, -3.0]).asCLPoint
      visible_region.farLeft = Point.new([40.0, -2.0]).asCLPoint
      visible_region.farRight = Point.new([41.0, -2.0]).asCLPoint

      region = Region.new(visible_region)
      region.as_bounds.should == [Point.new([41.0, -2.0]), Point.new([40.0, -3.0])]
    end
  end

  describe "comparison" do
    it "can compare to GMSCoordinateBounds" do
      @region1.should == @coordinate_bounds
      @region2.should != @coordinate_bounds
    end

    it "can compare to MKCoordinateRegion" do
      @region1.should == @coordinate_region
      @region2.should != @coordinate_region
    end
  end

  describe "conversion" do
    it "can convert into MKCoordinateRegion" do
      coordinate_region2 = @region1.asMKCoordinateRegion
      coordinate_region2.class.should == MKCoordinateRegion
      Point.new(coordinate_region2.center).should == @coordinate_region.center
      ((coordinate_region2.span.latitudeDelta - @coordinate_region.span.latitudeDelta) < 0.005).should == true
      ((coordinate_region2.span.longitudeDelta - @coordinate_region.span.longitudeDelta) < 0.005).should == true
    end

    it "can convert into GMSCoordinateBounds" do
      coordinate_bounds2 = @region1.asGMSCoordinateBounds
      coordinate_bounds2.class.should == GMSCoordinateBounds
      coordinate_bounds2.northEast.latitude.should == @coordinate_bounds.northEast.latitude
      coordinate_bounds2.northEast.longitude.should == @coordinate_bounds.northEast.longitude
      coordinate_bounds2.southWest.latitude.should == @coordinate_bounds.southWest.latitude
      coordinate_bounds2.southWest.longitude.should == @coordinate_bounds.southWest.longitude
    end
  end

end
