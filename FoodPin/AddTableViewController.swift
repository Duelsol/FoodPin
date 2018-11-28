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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // .Camera开启拍照
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // imagePicker回调
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }

    // saveButton点击事件
    @IBAction func saveButtonBeTapped(_ sender: Any) {
        let name = nameTextField.text
        let type = typeTextField.text
        let location = locationTextField.text
        if name == "" || type == "" || location == "" {
            let alert = UIAlertController(title: "请填写所有基本信息", message: nil, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            let restaurant = NSEntityDescription.insertNewObject(forEntityName: "Restaurant", into: managedObjectContext) as! Restaurant
            restaurant.make(name: name!, type: type!, location: location!, image: imageView.image!.pngData()!, isVisited: isVisited)
            do {
                try managedObjectContext.save()
            } catch {
                print("insert error")
            }
//            saveRecordToCloud(restaurant)
            performSegue(withIdentifier: "unwindToHomeScreen", sender: self)
        }
    }

    // yesButton点击事件
    @IBAction func yesButtonBeTapped(_ sender: Any) {
        yesButton.backgroundColor = UIColor.red
        noButton.backgroundColor = UIColor.gray
        isVisited = true
    }

    // noButton点击事件
    @IBAction func noButtonBeTapped(_ sender: Any) {
        yesButton.backgroundColor = UIColor.gray
        noButton.backgroundColor = UIColor.red
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
        do {
            try scaledImage?.jpegData(compressionQuality: 0.8)?.write(to: URL(fileURLWithPath: imageFilePath), options: .atomic)
        } catch {
            print("Failed to write image to file")
        }

        let imageFileURL = URL(fileURLWithPath: imageFilePath)
        let imageAsset = CKAsset(fileURL: imageFileURL)
        record.setValue(imageAsset, forKeyPath: "image")

        // 保存至iCloud
        let publicDatabase = CKContainer.default().publicCloudDatabase
        publicDatabase.save(record, completionHandler: {(recotd: CKRecord?, error: NSError?) -> Void in
            // 保存文件
            do {
                try FileManager.default.removeItem(atPath: imageFilePath)
            } catch {
                print("Failed to save record to the cloud")
            }
        } as! (CKRecord?, Error?) -> Void)
    }

}
