class MyAppleMapsViewController < UIViewController

  attr_accessor :map

  def init
    super
    self.title = 'Apple'
    self
  end

  def viewDidLoad
    self.map = AppleMap.new
    map.view.frame = self.view.frame
    map.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    map.delegate = self
    self.view.addSubview(map.view)
  end

  def viewDidAppear(animated)
    point = Point.new([40.4188, -3.7002])

    @annotation = MapAnnotation.new(image: UIImage.imageNamed('lite_27'),
                                   point: point,
                                   title: "300km",
                                   subtitle: "subtitle",
                                   show_callout: true
                                  )

    self.map.add_annotation(@annotation)
    self.map.center(point)
  end

end
