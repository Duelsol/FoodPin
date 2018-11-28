//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by Duelsol on 15/9/23.
//  Copyright © 2015年 Duelsol. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var dialogView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 黑色毛玻璃背景
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)

        // 渐渐变大效果
//        dialogView.transform = CGAffineTransformMakeScale(0.0, 0.0)
        // 从下滑入效果
//        dialogView.transform = CGAffineTransformMakeTranslation(0, 500)
        // 综合上面两个
        let scale = CGAffineTransform(scaleX: 0.0, y: 0.0)
        let translate = CGAffineTransform(translationX: 0, y: 500)
        dialogView.transform = scale.concatenating(translate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            // 渐渐变大效果
//            self.dialogView.transform = CGAffineTransformMakeScale(1, 1)
            // 从下划入效果
//            self.dialogView.transform = CGAffineTransformMakeTranslation(0, 0)
            // 综合上面两个
            let scale = CGAffineTransform(scaleX: 1, y: 1)
            let translate = CGAffineTransform(translationX: 0, y: 0)
            self.dialogView.transform = scale.concatenating(translate)
        }, completion: nil)
    }

}
