//
//  KeyboardChangingViewController.swift
//  FoodPin
//
//  Created by Duelsol on 15/10/21.
//  Copyright © 2015年 Duelsol. All rights reserved.
//

import UIKit

class KeyboardPopUpViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置右滑返回代理
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        // 捕捉屏幕中任何手势，这里是用来恢复键盘区域成初始位置
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTouches:")
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)

        // 注册键盘显示与隐藏的观察者
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func keyboardWillShow(note: NSNotification) {
        let userInfo  = note.userInfo as NSDictionary?
        let duration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue // 键盘弹出的动画事件
        let keyboardBounds = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let deltaY = keyboardBounds.size.height // 键盘的高
        let animations: (() -> Void) = {
            // 移动键盘区域
            self.keyboardView.transform = CGAffineTransformMakeTranslation(0, -deltaY)
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }

    func keyboardWillHide(note: NSNotification) {
        let userInfo  = note.userInfo as NSDictionary?
        let duration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations: (() -> Void) = {
            // 键盘区域位置还原
            self.keyboardView.transform = CGAffineTransformIdentity
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }
    
    func handleTouches(sender: UITapGestureRecognizer) {
        if sender.locationInView(self.view).y < self.view.bounds.height - 250 {
            // 取消输入框的第一响应
            textField.resignFirstResponder()
        }
    }

    // 测试按钮事件，进行各种古怪的实验
    @IBAction func buttonBeTapped(sender: AnyObject) {
        // 跳转系统设置界面
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        }
    }

}
