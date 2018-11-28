//
//  AboutViewController.swift
//  FoodPin
//
//  Created by Duelsol on 15/10/12.
//  Copyright © 2015年 Duelsol. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func sendEmail(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setToRecipients(["support@appcoda.com"])
            composer.navigationBar.tintColor = UIColor.white
            present(composer, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Failed to send mail: \(error!.localizedDescription)")
        default:
            break
        }
        dismiss(animated: true, completion: nil)
    }

}
