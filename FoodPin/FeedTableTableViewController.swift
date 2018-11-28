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
    var imageCache = NSCache<AnyObject, AnyObject>()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.getRecordsFormCloud()

        // 下拉刷新
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(FeedTableTableViewController.getRecordsFormCloud), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // 从iCloud获取数据，由于没有开发者账号所以无法测试
    @objc func getRecordsFormCloud() {
        restaurants = []
        // 获取iCloud公共数据
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        // 每一条记录获取结束后调用
        queryOperation.recordFetchedBlock = {(record: CKRecord!) -> Void in
            if let restaurantRecord = record {
                self.restaurants.append(restaurantRecord)
            }
        }
        // 所有查询结束后调用
        queryOperation.queryCompletionBlock = {(cursor: CKQueryOperation.Cursor?, error: NSError?) -> Void in
            self.refreshControl?.endRefreshing()
            if error != nil {
                print("Failed to get data from iCloud - \(error!.localizedDescription)")
            } else {
                print("Successfully retrieve the data from iCloud")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } as? (CKQueryOperation.Cursor?, Error?) -> Void
        publicDatabase.add(queryOperation)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if restaurants.isEmpty {
            return cell
        }

        let restaurant = restaurants[indexPath.row]
        cell.textLabel!.text = restaurant.__object(forKey: "name") as? String
        cell.imageView!.image = UIImage(named: "camera")// 默认图片

        // 先从NSCache缓存找，没有再下载
        if let imageFileURL = imageCache.object(forKey: restaurant.recordID) as? NSURL {
            print("Get image from cache")
            cell.imageView!.image = UIImage(data: NSData(contentsOf: imageFileURL as URL)! as Data)
        } else {
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .veryHigh
            fetchRecordsImageOperation.perRecordCompletionBlock = {(record: CKRecord?, recordId: CKRecord.ID?, error: NSError?) -> Void in
                if error != nil {
                    print("Failed to get restaurant image - \(error!.localizedDescription)")
                } else {
                    if let restaurantRecord = record {
                        DispatchQueue.main.async {
                            let imageAsset = restaurantRecord.__object(forKey: "image") as! CKAsset
                            cell.imageView!.image = UIImage(data: NSData(contentsOf: imageAsset.fileURL)! as Data)
                            self.imageCache.setObject(imageAsset.fileURL as AnyObject, forKey: restaurant.recordID)
                        }
                    }
                }
            } as? (CKRecord?, CKRecord.ID?, Error?) -> Void
            publicDatabase.add(fetchRecordsImageOperation)
        }

        return cell
    }

}
