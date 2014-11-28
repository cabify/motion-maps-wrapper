class MapTabController < UITabBarController

  def init
    super

    self.tabBar = tab_bar
    self.delegate = self
    self.viewControllers = [ MyGoogleMapsViewController.alloc.init,
                             MyAppleMapsViewController.alloc.init ]

    self
  end

  def tab_bar
    UITabBar.alloc.init.tap do |tabbar|
      tabbar.delegate = self
      tabbar.items = tab_bar_items
      tabbar.barStyle = UIBarStyleBlack
    end
  end

  def tab_bar_items
    [
      UITabBarItem.alloc.initWithTitle("Google", image:nil, tag:0),
      UITabBarItem.alloc.initWithTitle("Apple", image:nil, tag:0)
    ]
  end

end
