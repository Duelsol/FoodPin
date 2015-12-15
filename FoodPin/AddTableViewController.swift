//
//  AddTableViewController.swift
//  FoodPin
//
//  Created by Duelsol on 15/9/27.
//  Copyright © 2015年 Duelsol. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class AddTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!

    let imagePicker = UIImagePickerController()
    var isVisited = true

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            // .Camera开启拍照
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // imagePicker回调
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        dismissViewControllerAnimated(true, completion: nil)
    }

    // saveButton点击事件
    @IBAction func saveButtonBeTapped(sender: AnyObject) {
        let name = nameTextField.text
        let type = typeTextField.text
        let location = locationTextField.text
        if name == "" || type == "" || location == "" {
            let alert = UIAlertController(title: "请填写所有基本信息", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let restaurant = NSEntityDescription.insertNewObjectForEntityForName("Restaurant", inManagedObjectContext: managedObjectContext) as! Restaurant
            restaurant.make(name!, type: type!, location: location!, image: UIImagePNGRepresentation(imageView.image!)!, isVisited: isVisited)
            do {
                try managedObjectContext.save()
            } catch {
                print("insert error")
            }
//            saveRecordToCloud(restaurant)
            performSegueWithIdentifier("unwindToHomeScreen", sender: self)
        }
    }

    // yesButton点击事件
    @IBAction func yesButtonBeTapped(sender: AnyObject) {
        yesButton.backgroundColor = UIColor.redColor()
        noButton.backgroundColor = UIColor.grayColor()
        isVisited = true
    }

    // noButton点击事件
    @IBAction func noButtonBeTapped(sender: AnyObject) {
        yesButton.backgroundColor = UIColor.grayColor()
        noButton.backgroundColor = UIColor.redColor()
        isVisited = false
    }

    func saveRecordToCloud(restaurant: Restaurant!) -> Void {
        let record = CKRecord(recordType: "Restaurant")
        record.setValue(restaurant.name, forKeyPath: "name")
        record.setValue(restaurant.type, forKeyPath: "type")
        record.setValue(restaurant.location, forKeyPath: "location")

        // 图片缩放
        let originalImage = UIImage(data: restaurant.image)
        let scalingFactor = (originalImage!.size.width > 1024) ? 1024 / originalImage!.size.width : 1.0
        let scaledImage = UIImage(data: restaurant.image, scale: scalingFactor)

        // 存储到临时目录
        let imageFilePath = NSTemporaryDirectory() + restaurant.name
        UIImageJPEGRepresentation(scaledImage!, 0.8)?.writeToFile(imageFilePath, atomically: true)

        let imageFileURL = NSURL(fileURLWithPath: imageFilePath)
        let imageAsset = CKAsset(fileURL: imageFileURL)
        record.setValue(imageAsset, forKeyPath: "image")

        // 保存至iCloud
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        publicDatabase.saveRecord(record, completionHandler: {(recotd: CKRecord?, error: NSError?) -> Void in
            // 保存文件
            do {
                try NSFileManager.defaultManager().removeItemAtPath(imageFilePath)
            } catch {
                print("Failed to save record to the cloud")
            }
        })
    }

}

// 借个地方放一下，下面是输入框的基本验证
extension UITextField {

    var notEmpty: Bool {
        get {
            return self.text != ""
        }
    }

    func validate(RegEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", RegEx)
        return predicate.evaluateWithObject(self.text)
    }

    func validateEmail() -> Bool {
        return self.validate("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
    }

    func validatePhoneNumber() -> Bool {
        return self.validate("^\\d{11}$")
    }

    func validatePassword() -> Bool {
        return self.validate("^[A-Z0-9a-z]{6,18}")
    }

}
