def add_shared_maps_specs(instance)
  instance.instance_eval do

    describe "annotations" do

      before do
        @annotations = [
          MapAnnotation.new(point: [-33.868, 151.2086],
                            title: "Hello World",
                            animated: true,
                            image: UIImage.imageNamed("drop_off")),
          MapAnnotation.new(point: [-33.868, 152.2086],
                            title: "Hello World 2",
                            animated: true,
                            image: UIImage.imageNamed("pick_up")),
          MapAnnotation.new(point: [-32.868, 151.2086],
                            title: "Hello World 3",
                            animated: true,
                            image: UIImage.imageNamed("lite_27")),
        ]

        controller.add_annotations(@annotations)
        controller.select_annotation(@annotations.first)
      end

      after do
        controller.clear_annotations
      end

      it "can add and remove annotations" do
        controller.annotations.count.should == 3
      end

      it "can remove annotations" do
        controller.remove_annotations(@annotations)
        controller.annotations.count.should == 0
      end

     it "can select annotations" do
        controller.selected_annotations.include?(@annotations.first).should == true
      end

      it "can deselect annotations" do
        controller.deselect_annotation(@annotations.first)
        controller.selected_annotations.count.should == 0
      end
    end

    describe "coordinates" do

      it "can set the center of the map" do
        point = Point.new([40.417217, -3.703539])
        controller.center=(point)
        controller.center.equals?(point).should == true
      end

      it "can set a region in the map" do
        points = [
          [40.433385, -3.706487],
          [40.444751, -3.636793],
          [40.393980, -3.626109],
          [40.385350, -3.723955]
        ]
        region = Region.new(points: points)
        controller.region=(region)

        if controller.is_a?(AppleMapsViewController)
          # When setting a new region, the map adjusts the values to fit the visible area of the map
          visible_region = Region.new(controller.mapView.regionThatFits(region.asMKCoordinateRegion))
          controller.region.should == visible_region
        elsif controller.is_a?(GoogleMapsViewController)
          # We cannot know the final regin that the map will display when we set a region,
          # but we know the camera target and zoom it will display.
          camera = controller.mapView.cameraForBounds(region.asGMSCoordinateBounds, insets: UIEdgeInsetsMake(0,0,0,0))
          controller.mapView.camera.zoom.should == camera.zoom
          Point.new(controller.mapView.camera.target).should == camera.target
        end

      end

    end

    describe "map view" do
      before do
        controller.disable_map
        @initial_region = controller.region
      end

      it "can be enabled" do
        controller.enable_map
        pinch_open(controller.mapView)
        wait 0.5 do
          controller.region.should != @initial_region
        end
      end

      it "can be disabled" do
        pinch_open(controller.mapView)
        wait 0.5 do
          controller.region.should == @initial_region
        end
      end
    end
  end
end
