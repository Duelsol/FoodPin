//
//  DetailViewController.swift
//  FoodPin
//
//  Created by Duelsol on 15/9/12.
//  Copyright (c) 2015年 Duelsol. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var restaurant: Restaurant!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 标题名
        title = self.restaurant.name

        // Self Sizing Cell
        tableView.estimatedRowHeight = 36
        tableView.rowHeight = UITableViewAutomaticDimension

        // Do any additional setup after loading the view.
        self.restaurantImageView.image = UIImage(data: restaurant.image)
        // 改变表格背景色
        self.tableView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.2)
        // 去除多余行
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // 行下划线颜色
        self.tableView.separatorColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.8)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // 是否隐藏标题栏
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // 解决Self Sizing Cell的bug
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! DetailTableViewCell

        cell.mapButton.hidden = true

        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "Name"
            cell.valueLabel.text = restaurant.name
        case 1:
            cell.fieldLabel.text = "Type"
            cell.valueLabel.text = restaurant.type
        case 2:
            cell.fieldLabel.text = "Location"
            cell.valueLabel.text = restaurant.location
            cell.mapButton.hidden = false
        case 3:
            cell.fieldLabel.text = "Been here"
            cell.valueLabel.text = restaurant.isVisited ? "Yes, I've been here before" : "No"
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }

        // 去除行背景色
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }

    // 转场时调用
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap" {
            let destinationController = segue.destinationViewController as! MapViewController
            destinationController.restaurant = restaurant
        }
    }

    @IBAction func close(segue: UIStoryboardSegue) {

    }

}
