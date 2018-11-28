//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by Duelsol on 15/9/5.
//  Copyright (c) 2015年 Duelsol. All rights reserved.
//

import UIKit
import CoreData

class RestaurantTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {

    var restaurants: [Restaurant] = [Restaurant]()
    var fetchResultController: NSFetchedResultsController<NSFetchRequestResult>!
    var searchController: UISearchController!
    var searchResults: [Restaurant] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // 判断是否展示导航页面
        let defaults = UserDefaults.standard
        let hasViewedWalkthrough = defaults.bool(forKey: "hasViewedWalkthrough")
        if !hasViewedWalkthrough {
            if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? PageViewController {
                present(pageViewController, animated: true, completion: nil)
            }
        }

        // 查询数据
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
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
            for i in 0 ..< Restaurant.restaurantNames.count {
                let restaurant = NSEntityDescription.insertNewObject(forEntityName: "Restaurant", into: managedObjectContext) as! Restaurant
                restaurant.make(name: Restaurant.restaurantNames[i], type: Restaurant.restauranyTypes[i], location: Restaurant.restaurantLocations[i], image: UIImage(named: Restaurant.restaurantImages[i])!.pngData()!, isVisited: Restaurant.restaurantIsVisited[i])
                do {
                    try managedObjectContext.save()
                } catch {
                    print("insert error")
                }
            }
        }

        // 调用webservice
        let urlString = "http://127.0.0.1:8080/list"
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if data != nil && error == nil {
                do {
                    let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    print(response)
                } catch {

                }
            }
        })

        // 去除返回按钮文字
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // 搜索框
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search your restaurant"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return self.searchResults.count
        } else {
            return self.restaurants.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CustomTableViewCell

        let restaurant = searchController.isActive ? searchResults[indexPath.row] : restaurants[indexPath.row]
        cell.nameLabel.text = restaurant.name
        cell.locationLabel.text = restaurant.location
        cell.typeLabel.text = restaurant.type
        cell.accessoryType = restaurant.isVisited ? .checkmark : .none

        // 圆形图标
        cell.thumbnailImageView.image = UIImage(data: restaurant.image)
        cell.thumbnailImageView.layer.cornerRadius = cell.thumbnailImageView.frame.size.width / 2
        cell.thumbnailImageView.clipsToBounds = true

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: UIAlertController.Style.actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        optionMenu.addAction(cancelAction)

        let callActionHandler = { (action: UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "Service Unavailable", message: "Sorry, the call feature is not available yet. Please retry later.", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertMessage, animated: true, completion: nil)
        }
        let callAction = UIAlertAction(title: "Call " + "123-000-\(indexPath.row)", style: .default, handler: callActionHandler)
        optionMenu.addAction(callAction)

        let isVisitedAction = UIAlertAction(title: "I've been here", style: .default, handler: { (action: UIAlertAction) -> Void in
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            self.restaurants[indexPath.row].isVisited = true
        })
        optionMenu.addAction(isVisitedAction)

        self.present(optionMenu, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: 动态更新tableView

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        default:
            tableView.reloadData()
        }
        restaurants = controller.fetchedObjects as! [Restaurant]
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    // 启动右划的方法
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }

    // 自定义右划，上面的方法还要，但是里面内容无效
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .default, title: "Share", handler: {(action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            let shareMenu = UIAlertController(title: nil, message: "Share using", preferredStyle: .actionSheet)
            let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: nil)
            let facebookAction = UIAlertAction(title: "Facebook", style: .default, handler: nil)
            let emailAction = UIAlertAction(title: "Email", style: .default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            shareMenu.addAction(twitterAction)
            shareMenu.addAction(facebookAction)
            shareMenu.addAction(emailAction)
            shareMenu.addAction(cancelAction)
            self.present(shareMenu, animated: true, completion: nil)
        })

        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: {(action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            let restaurantToDelete = self.fetchResultController.object(at: indexPath) as! Restaurant
            managedObjectContext.delete(restaurantToDelete)
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
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !searchController.isActive
    }

    // MARK: 搜索框筛选数据

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        filterContentForSearchText(searchText: searchText!)
        tableView.reloadData()
    }

    func filterContentForSearchText(searchText: String) {
        searchResults = restaurants.filter({(restaurant: Restaurant) -> Bool in
            if searchText == "" {
                return true
            }
            let nameMatch = restaurant.name.range(of: searchText, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)
            return nameMatch != nil
        })
    }

    // 转场时调用
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! DetailViewController
                destinationController.restaurant = searchController.isActive ? searchResults[indexPath.row] : restaurants[indexPath.row]
            }
        }
    }

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
    }

}
