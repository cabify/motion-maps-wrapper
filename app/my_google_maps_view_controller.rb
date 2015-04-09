class MyGoogleMapsViewController < UIViewController
  include GoogleMapsViewController

  def init
    super
    self.title = 'Google'
    self
  end

  def viewDidAppear(animated)

    point = Point.new([40.4188, -3.7002])

    annotation = MapAnnotation.new(image: UIImage.imageNamed('lite_27'),
                                   point: point,
                                   title: "300km",
                                   subtitle: "subtitle",
                                   show_callout: true,
                                  )

    self.add_annotation(annotation)
    puts "viewDidAppear"
    self.center(point)
  end
end
