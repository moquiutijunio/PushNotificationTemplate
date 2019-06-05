//
//  ViewController.swift
//  PushNotificationTemplate
//
//  Created by Junio Moquiuti on 05/06/19.
//  Copyright © 2019 Junio Moquiuti. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receivedNewPushNotification),
                                               name: .didReceiveRemoteNotification,
                                               object: nil)
    }

    @objc private func receivedNewPushNotification(_ notification: Notification) {
        guard let pushNotification = notification.object as? PushNotification else { return }

        let alert = UIAlertController(title: pushNotification.title,
                                      message: pushNotification.message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        present(alert, animated: true)
    }

    deinit {
        
        NotificationCenter.default.removeObserver(self,
                                                  name: .didReceiveRemoteNotification,
                                                  object: nil)
    }
}
