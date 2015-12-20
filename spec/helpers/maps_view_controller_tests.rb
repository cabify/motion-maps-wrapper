def add_shared_maps_specs(instance)
  instance.instance_eval do
    before do
      @delegate = Object.new
      controller.map.delegate = @delegate
    end

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

        controller.map.add_annotations(@annotations)
      end

      after do
        controller.map.clear_annotations
      end

      it "can add and remove annotations" do
        controller.map.annotations.count.should == 3
      end

      it "can remove annotations" do
        controller.map.remove_annotations(@annotations)
        controller.map.annotations.count.should == 0
      end

      it "can select annotations" do
        @delegate.mock!(:did_select_annotation) do |annotation|
          annotation.should == @annotations.first
          resume
        end

        Dispatch::Queue.main.after(0.1) {
          controller.map.select_annotation(@annotations.first)
          controller.map.center(@annotations.first.point)
          controller.map.selected_annotations.include?(@annotations.first).should == true
        }

        wait_max 2 {
          @delegate.reset(:did_select_annotation)
        }
      end

      it "can deselect annotations" do
        controller.map.select_annotation(@annotations.first)
        controller.map.center(@annotations.first.point)

        @delegate.mock!(:did_deselect_annotation) do |annotation|
          annotation.should == @annotations.first
          resume
        end

        Dispatch::Queue.main.after(0.1) {
          controller.map.deselect_annotation(@annotations.first)
          controller.map.selected_annotations.count.should == 0
        }

        wait_max 2 {
          # FIXME
          @delegate.metaclass.send(:remove_method, :did_deselect_annotation)
          # @delegate.reset(:did_deselect_annotation)
        }
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
        @delegate.mock!(:map_will_move) do |opts|
          opts[:gesture].should == false
          opts[:animated].should == false
        end

        @delegate.mock!(:map_did_move) do |opts|
          opts[:gesture].should == false
          opts[:animated].should == false
          opts[:position].should == controller.map.center
          resume
        end

        Dispatch::Queue.main.after(0.1) {
          controller.map.center(@point)
          controller.map.center.equals?(@point).should == true
        }

        wait_max 2 {
          @delegate.reset(:map_will_move)
          @delegate.reset(:map_did_move)
        }
      end

      it "can set the center animated" do
        @delegate.mock!("map_will_move:") do |opts|
          opts[:gesture].should == false
          opts[:animated].should == true
        end

        @delegate.mock!("map_did_move:") do |opts|
          opts[:gesture].should == false
          opts[:animated].should == true
          opts[:position].should == @point
          controller.map.center.should == @point
          resume
        end

        controller.map.center(@point, animated:true)

        wait_max 2 {
          @delegate.reset(:map_will_move)
          @delegate.reset(:map_did_move)
        }
      end

      it "can set a region in the map" do
        @delegate.mock!("map_will_move:") do |opts|
          opts[:gesture].should == false
          opts[:animated].should == false
        end

        @delegate.mock!("map_did_move:") do |opts|
          opts[:gesture].should == false
          opts[:animated].should == false
          opts[:position].should == controller.map.center
          resume
        end

        Dispatch::Queue.main.after(0.1) {
          controller.map.region(@region)

          if controller.map.is_a?(AppleMap)
            # When setting a new region, the map adjusts the values to fit the visible area of the map
            visible_region = Region.new(controller.map.view.regionThatFits(@region.asMKCoordinateRegion))
            controller.map.region.should == visible_region
          elsif controller.map.is_a?(GoogleMap)
            # We cannot know the final regin that the map will display when we set a region,
            # but we know the camera target and zoom it will display.
            camera = controller.map.view.cameraForBounds(@region.asGMSCoordinateBounds, insets: UIEdgeInsetsMake(0,0,0,0))
            controller.map.view.camera.zoom.should == camera.zoom
            Point.new(controller.map.view.camera.target).should == camera.target
          end
        }

        wait_max 2 {
          @delegate.reset(:map_will_move)
          @delegate.reset(:map_did_move)
        }
      end

      it "can set a region animated" do
        @delegate.mock!(:map_will_move) do |opts|
          opts[:gesture].should == false
          opts[:animated].should == true
        end

        @delegate.mock!(:map_did_move) do |opts|
          opts[:gesture].should == false
          opts[:animated].should == true
          opts[:position].should == controller.map.center
          resume
        end

        controller.map.region(@region, animated:true)

        wait_max 2 {
          @delegate.reset(:map_will_move)
          @delegate.reset(:map_did_move)
        }
      end

      it "recieves callbacks when user drags the map" do
        @delegate.mock!(:map_will_move) do |opts|
          opts[:gesture].should == true
          opts[:animated].should == false
        end

        @delegate.mock!(:map_did_move) do |opts|
          opts[:gesture].should == true
          opts[:animated].should == false
          opts[:position].should == controller.map.center
          resume
        end

        Dispatch::Queue.main.after(0.1) {
          drag(controller.map.view, :from => :bottom)
        }

        wait_max 20 {
          @delegate.reset(:map_will_move)
          @delegate.reset(:map_did_move)
        }
      end

    end

    describe "map view" do
      before do
        controller.map.disable_map
        @initial_region = controller.map.region
      end

      it "can be enabled" do
        controller.map.enable_map
        pinch_open(controller.map.view)
        wait 0.5 do
          controller.map.region.should != @initial_region
        end
        controller.map.enabled.should == true
      end

      it "can be disabled" do
        pinch_open(controller.map.view)
        wait 0.5 do
          controller.map.region.should == @initial_region
        end
        controller.map.enabled.should == false
      end

      it "can find the logo view" do
        controller.map.maps_logo_view.should != nil
      end
    end
  end
end
