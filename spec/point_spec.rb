describe "Point" do
  describe "initialization" do
    it "can be initialized with a CLLocationCoordinate2D" do
      coordinate = CLLocationCoordinate2DMake(40.456116, -3.671297)
      point = Point.new(coordinate)
      point.latitude.should == coordinate.latitude
      point.longitude.should == coordinate.longitude
    end

    it "can be initialized with a MKUserLocation" do
      array = [40.456116, -3.671297]
      user_location = MKUserLocation.alloc.init
      user_location = Point.new(array).asCLLocation
      point = Point.new(array)
      point.latitude.should == array[0]
      point.longitude.should == array[1]
    end

    it "can be initialized with another Point" do
      point1 = Point.new([40.456116, -3.671297])
      point2 = Point.new(point1)
      point1.__id__.should == point2.__id__
    end

    it "can be initialized with an Array" do
      array = [40.456116, -3.671297]
      point = Point.new(array)
      point.latitude.should == array[0]
      point.longitude.should == array[1]
    end
  end

  describe "comparison" do
    it "can be compared to a CLLocationCoordinate2D" do
      array = [40.456116, -3.671297]
      coordinate = CLLocationCoordinate2DMake(array[0], array[1])
      point = Point.new(array)
      point.should == coordinate
    end

    it "can de compared to another Point" do
      point1 = Point.new([40.456116, -7.351682])
      point2 = Point.new([33.4341668 -3.671297])
      point3 = Point.new([33.4341668 -3.671297])
      point1.should != point2
      point2.should == point3
    end
  end

  describe "conversion" do
    it "can convert into CLLocationCoordinate2D" do
      array = [40.456116, -3.671297]
      point = Point.new(array)
      coordinate = point.asCLPoint
      coordinate.class.should == CLLocationCoordinate2D
      coordinate.latitude.should == array[0]
      coordinate.longitude.should == array[1]
    end

    it "can converto into CLLocation" do
      array = [40.456116, -3.671297]
      point = Point.new(array)
      location = point.asCLLocation
      location.class.should == CLLocation
      location.coordinate.latitude.should == array[0]
      location.coordinate.longitude.should == array[1]
    end
  end
end
