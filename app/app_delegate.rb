class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    GMSServices.provideAPIKey("AIzaSyCIA5qrvpVGaR6o0t_Vy96SeQLrieRiUQk")
    return true if RUBYMOTION_ENV == 'test'

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @window.rootViewController = MapTabController.alloc.init
    @window.backgroundColor = UIColor.whiteColor
    @window.makeKeyAndVisible
    true
  end
end
