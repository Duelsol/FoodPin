//
//  FeedTableTableViewController.swift
//  FoodPin
//
//  Created by Duelsol on 15/10/14.
//  Copyright © 2015年 Duelsol. All rights reserved.
//

import UIKit
import CloudKit

class FeedTableTableViewController: UITableViewController {

    var restaurants: [CKRecord] = []
    var imageCache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.getRecordsFormCloud()

        // 下拉刷新
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.whiteColor()
        refreshControl?.tintColor = UIColor.grayColor()
        refreshControl?.addTarget(self, action: "getRecordsFormCloud", forControlEvents: .ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // 从iCloud获取数据，由于没有开发者账号所以无法测试
    func getRecordsFormCloud() {
        restaurants = []
        // 获取iCloud公共数据
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name"]
        queryOperation.queuePriority = .VeryHigh
        queryOperation.resultsLimit = 50
        // 每一条记录获取结束后调用
        queryOperation.recordFetchedBlock = {(record: CKRecord!) -> Void in
            if let restaurantRecord = record {
                self.restaurants.append(restaurantRecord)
            }
        }
        // 所有查询结束后调用
        queryOperation.queryCompletionBlock = {(cursor: CKQueryCursor?, error: NSError?) -> Void in
            self.refreshControl?.endRefreshing()
            if error != nil {
                print("Failed to get data from iCloud - \(error!.localizedDescription)")
            } else {
                print("Successfully retrieve the data from iCloud")
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        }
        publicDatabase.addOperation(queryOperation)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if restaurants.isEmpty {
            return cell
        }

        let restaurant = restaurants[indexPath.row]
        cell.textLabel!.text = restaurant.objectForKey("name") as? String
        cell.imageView!.image = UIImage(named: "camera")// 默认图片

        // 先从NSCache缓存找，没有再下载
        if let imageFileURL = imageCache.objectForKey(restaurant.recordID) as? NSURL {
            print("Get image from cache")
            cell.imageView!.image = UIImage(data: NSData(contentsOfURL: imageFileURL)!)
        } else {
            let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .VeryHigh
            fetchRecordsImageOperation.perRecordCompletionBlock = {(record: CKRecord?, recordId: CKRecordID?, error: NSError?) -> Void in
                if error != nil {
                    print("Failed to get restaurant image - \(error!.localizedDescription)")
                } else {
                    if let restaurantRecord = record {
                        dispatch_async(dispatch_get_main_queue(), {
                            let imageAsset = restaurantRecord.objectForKey("image") as! CKAsset
                            cell.imageView!.image = UIImage(data: NSData(contentsOfURL: imageAsset.fileURL)!)
                            self.imageCache.setObject(imageAsset.fileURL, forKey: restaurant.recordID)
                        })
                    }
                }
            }
            publicDatabase.addOperation(fetchRecordsImageOperation)
        }

        return cell
    }

}
