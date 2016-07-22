//
//  PageViewController.swift
//  FoodPin
//
//  Created by Duelsol on 15/10/8.
//  Copyright © 2015年 Duelsol. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var pageHeadings = ["Personalize", "Locate", "Discover"]
    var pageImages = ["homei", "mapintro", "fiveleaves"]
    var pageSubHeadings = ["Pin you favourite restaurants and create your own food guide", "Search and locate your favourite restaurant on Maps", "Find restaurants pinned by your friends and other foodies around the world"]

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self

        if let startingViewController = self.viewControllerAtIndex(0) {
            setViewControllers([startingViewController], direction: .Forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // 下一个page
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PageContentViewController).index
        index += 1
        return self.viewControllerAtIndex(index)
    }

    // 上一个page
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PageContentViewController).index
        index -= 1
        return self.viewControllerAtIndex(index)
    }

    func viewControllerAtIndex(index: Int) -> PageContentViewController? {
        if index == NSNotFound || index < 0 || index >= self.pageHeadings.count {
            return nil
        }
        if let pageContentViewController = storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as? PageContentViewController {
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.subHeading = pageSubHeadings[index]
            pageContentViewController.index = index
            return pageContentViewController
        }
        return nil
    }

    func forward(index: Int) {
        if let nextViewController = self.viewControllerAtIndex(index + 1) {
            setViewControllers([nextViewController], direction: .Forward, animated: true, completion: nil)
        }
    }

}
