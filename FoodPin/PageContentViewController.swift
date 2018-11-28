//
//  PageContentViewController.swift
//  FoodPin
//
//  Created by Duelsol on 15/10/8.
//  Copyright © 2015年 Duelsol. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subHeadingLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!

    var index: Int = 0
    var heading: String = ""
    var imageFile: String = ""
    var subHeading: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        headingLabel.text = heading
        subHeadingLabel.text = subHeading
        contentImageView.image = UIImage(named: imageFile)
        pageControl.currentPage = index
        getStartedButton.isHidden = (index == 2) ? false : true
        forwardButton.isHidden = (index == 2) ? true : false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func close(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "hasViewedWalkthrough")

        dismiss(animated: true, completion: nil)
    }

    @IBAction func nextScreen(_ sender: Any) {
        let pageViewController = self.parent as! PageViewController
        pageViewController.forward(index: index)
    }

}
