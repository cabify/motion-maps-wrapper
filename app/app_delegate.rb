class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    GMSServices.provideAPIKey(NSBundle.mainBundle.infoDictionary["google_maps_api_key"])
    return true if RUBYMOTION_ENV == 'test'

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @window.rootViewController = MapTabController.alloc.init
    @window.backgroundColor = UIColor.whiteColor
    @window.makeKeyAndVisible
    true
  end
end
