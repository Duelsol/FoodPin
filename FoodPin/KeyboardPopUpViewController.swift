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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTouches(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)

        // 注册键盘显示与隐藏的观察者
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        // 关闭监听
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        let userInfo  = notification.userInfo as NSDictionary?
        let duration = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue // 键盘弹出的动画事件
        let keyboardBounds = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = keyboardBounds.size.height // 键盘的高
        let animations: (() -> Void) = {
            // 移动键盘区域
            self.keyboardView.transform = CGAffineTransform(translationX: 0, y: -deltaY)
        }
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt((userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        let userInfo  = notification.userInfo as NSDictionary?
        let duration = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations: (() -> Void) = {
            // 键盘区域位置还原
            self.keyboardView.transform = CGAffineTransform.identity
        }
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt((userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }
    
    @objc func handleTouches(_ sender: UITapGestureRecognizer) {
        if sender.location(in: self.view).y < self.view.bounds.height - 250 {
            // 取消输入框的第一响应
            textField.resignFirstResponder()
        }
    }

    // 测试按钮事件，进行各种实验
    @IBAction func buttonBeTapped(_ sender: Any) {
        // 跳转系统设置界面
        let url = URL(string: UIApplication.openSettingsURLString)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }

}
