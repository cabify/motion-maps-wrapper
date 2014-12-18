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

      before do
        points = [
          [40.433385, -3.706487],
          [40.444751, -3.636793],
          [40.393980, -3.626109],
          [40.385350, -3.723955],
          [rand(40),rand(10)]
        ]
        @region = Region.new(points: points)
        @point = Point.new([rand(40),rand(10)])
      end

      it "can set the center of the map" do
        controller.mock!(:map_will_move) do |opts|
          opts[:gesture].should == false
          opts[:animated].should == false
        end

        controller.mock!(:map_did_move) do |opts|
          opts[:gesture].should == false
          opts[:animated].should == false
          opts[:position].should == controller.center
          resume
        end

        Dispatch::Queue.main.after(0.1) {
          controller.center(@point)
          controller.center.equals?(@point).should == true
        }

        wait_max 2 {
          controller.reset(:map_will_move)
          controller.reset(:map_did_move)
        }
      end

      it "can set the center animated" do
        controller.mock!(:map_will_move) do |opts|
          opts[:gesture].should == false
          opts[:animated].should == true
        end

        controller.mock!(:map_did_move) do |opts|
          opts[:gesture].should == false
          opts[:animated].should == true
          opts[:position].should == @point
          controller.center.should == @point
          resume
        end

        controller.center(@point, animated:true)

        wait_max 2 {
          controller.reset(:map_will_move)
          controller.reset(:map_did_move)
        }
      end

      it "can set a region in the map" do
        controller.mock!("map_will_move:") do |opts|
          opts[:gesture].should == false
          opts[:animated].should == false
        end

        controller.mock!("map_did_move:") do |opts|
          opts[:gesture].should == false
          opts[:animated].should == false
          opts[:position].should == controller.center
          resume
        end

        Dispatch::Queue.main.after(0.1) {
          controller.region(@region)

          if controller.is_a?(AppleMapsViewController)
            # When setting a new region, the map adjusts the values to fit the visible area of the map
            visible_region = Region.new(controller.mapView.regionThatFits(@region.asMKCoordinateRegion))
            controller.region.should == visible_region
          elsif controller.is_a?(GoogleMapsViewController)
            # We cannot know the final regin that the map will display when we set a region,
            # but we know the camera target and zoom it will display.
            camera = controller.mapView.cameraForBounds(@region.asGMSCoordinateBounds, insets: UIEdgeInsetsMake(0,0,0,0))
            controller.mapView.camera.zoom.should == camera.zoom
            Point.new(controller.mapView.camera.target).should == camera.target
          end
        }

        wait_max 2 {
          controller.reset(:map_will_move)
          controller.reset(:map_did_move)
        }
      end

      it "can set a region animated" do
        controller.mock!(:map_will_move) do |opts|
          opts[:gesture].should == false
          opts[:animated].should == true
        end

        controller.mock!(:map_did_move) do |opts|
          opts[:gesture].should == false
          opts[:animated].should == true
          opts[:position].should == controller.center
          resume
        end

        controller.region(@region, animated:true)

        wait_max 2 {
          controller.reset(:map_will_move)
          controller.reset(:map_did_move)
        }
      end

      it "recieves callbacks when user drags the map" do
        controller.mock!(:map_will_move) do |opts|
          opts[:gesture].should == true
          opts[:animated].should == false
        end

        controller.mock!(:map_did_move) do |opts|
          opts[:gesture].should == true
          opts[:animated].should == false
          opts[:position].should == controller.center
          resume
        end

        Dispatch::Queue.main.after(0.1) {
          drag(controller.mapView, :from => :bottom)
        }

        wait_max 20 {
          controller.reset(:map_will_move)
          controller.reset(:map_did_move)
        }
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
