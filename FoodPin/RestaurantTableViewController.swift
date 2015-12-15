//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by Duelsol on 15/9/5.
//  Copyright (c) 2015年 Duelsol. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class RestaurantTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {

    var restaurants: [Restaurant] = [Restaurant]()
    var fetchResultController: NSFetchedResultsController!
    var searchController: UISearchController!
    var searchResults: [Restaurant] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // 判断是否展示导航页面
        let defaults = NSUserDefaults.standardUserDefaults()
        let hasViewedWalkthrough = defaults.boolForKey("hasViewedWalkthrough")
        if !hasViewedWalkthrough {
            if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as? PageViewController {
                self.presentViewController(pageViewController, animated: true, completion: nil)
            }
        }

        // 查询数据
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

        let fetchRequest = NSFetchRequest(entityName: "Restaurant")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
            restaurants = fetchResultController.fetchedObjects as! [Restaurant]
        } catch {
            print("select error")
        }

//        do {
//            try restaurants = managedObjectContext.executeFetchRequest(fetchRequest) as! [Restaurant]
//        } catch {
//            print("Failed To retrieve record")
//        }

        // 如果没数据，插入默认数据
        if restaurants.count == 0 {
            for var i = 0; i < Restaurant.restaurantNames.count; i++ {
                let restaurant = NSEntityDescription.insertNewObjectForEntityForName("Restaurant", inManagedObjectContext: managedObjectContext) as! Restaurant
                restaurant.make(Restaurant.restaurantNames[i], type: Restaurant.restauranyTypes[i], location: Restaurant.restaurantLocations[i], image: UIImagePNGRepresentation(UIImage(named: Restaurant.restaurantImages[i])!)!, isVisited: Restaurant.restaurantIsVisited[i])
                do {
                    try managedObjectContext.save()
                } catch {
                    print("insert error")
                }
            }
        }

        // 调用webservice：原生 vs 第三方
        let urlString = "http://127.0.0.1:8080/demo"
        let url = NSURL(string: urlString)
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if data != nil && error == nil {
                do {
                    let response = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    print(response["detail"])
                } catch {

                }
            }
        })
        Alamofire.request(.GET, urlString).responseJSON(completionHandler: {
            response in
            if let value = response.result.value {
                let json = JSON(value)
                print(json["detail"])
            }
        })

        // 去除返回按钮文字
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        // 搜索框
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search your restaurant"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return self.searchResults.count
        } else {
            return self.restaurants.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CustomTableViewCell

        let restaurant = searchController.active ? searchResults[indexPath.row] : restaurants[indexPath.row]
        cell.nameLabel.text = restaurant.name
        cell.locationLabel.text = restaurant.location
        cell.typeLabel.text = restaurant.type
        cell.accessoryType = restaurant.isVisited ? .Checkmark : .None

        // 圆形图标
        cell.thumbnailImageView.image = UIImage(data: restaurant.image)
        cell.thumbnailImageView.layer.cornerRadius = cell.thumbnailImageView.frame.size.width / 2
        cell.thumbnailImageView.clipsToBounds = true

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        optionMenu.addAction(cancelAction)

        let callActionHandler = { (action: UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "Service Unavailable", message: "Sorry, the call feature is not available yet. Please retry later.", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertMessage, animated: true, completion: nil)
        }
        let callAction = UIAlertAction(title: "Call " + "123-000-\(indexPath.row)", style: .Default, handler: callActionHandler)
        optionMenu.addAction(callAction)

        let isVisitedAction = UIAlertAction(title: "I've been here", style: .Default, handler: { (action: UIAlertAction) -> Void in
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
            self.restaurants[indexPath.row].isVisited = true
        })
        optionMenu.addAction(isVisitedAction)

        self.presentViewController(optionMenu, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    // MARK: 动态更新tableView

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:
            tableView.reloadData()
        }
        restaurants = controller.fetchedObjects as! [Restaurant]
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    // 启动右划的方法
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    // 自定义右划，上面的方法还要，但是里面内容无效
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .Default, title: "Share", handler: {(action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            let shareMenu = UIAlertController(title: nil, message: "Share using", preferredStyle: .ActionSheet)
            let twitterAction = UIAlertAction(title: "Twitter", style: .Default, handler: nil)
            let facebookAction = UIAlertAction(title: "Facebook", style: .Default, handler: nil)
            let emailAction = UIAlertAction(title: "Email", style: .Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            shareMenu.addAction(twitterAction)
            shareMenu.addAction(facebookAction)
            shareMenu.addAction(emailAction)
            shareMenu.addAction(cancelAction)
            self.presentViewController(shareMenu, animated: true, completion: nil)
        })

        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {(action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let restaurantToDelete = self.fetchResultController.objectAtIndexPath(indexPath) as! Restaurant
            managedObjectContext.deleteObject(restaurantToDelete)
            do {
                try managedObjectContext.save()
            } catch {
                print("delete error")
            }
        })

        shareAction.backgroundColor = UIColor(red: 255/255, green: 166/255, blue: 51/255, alpha: 1)
        deleteAction.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        return [deleteAction, shareAction]
    }

    // 如果激活搜索框则不显示右划的方法
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !searchController.active
    }

    // MARK: 搜索框筛选数据

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        filterContentForSearchText(searchText!)
        tableView.reloadData()
    }

    func filterContentForSearchText(searchText: String) {
        searchResults = restaurants.filter({(restaurant: Restaurant) -> Bool in
            if searchText == "" {
                return true
            }
            let nameMatch = restaurant.name.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil)
            return nameMatch != nil
        })
    }

    // 转场时调用
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destinationViewController as! DetailViewController
                destinationController.restaurant = searchController.active ? searchResults[indexPath.row] : restaurants[indexPath.row]
            }
        }
    }

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
    }

}
