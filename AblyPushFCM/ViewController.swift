//
//  ViewController.swift
//  AblyPushFCM
//
//  Created by Ricardo Pereira on 06/06/2019.
//  Copyright © 2019 Whitesmith. All rights reserved.
//

import UIKit
import Ably

class ViewController: UIViewController {

    let options = ARTClientOptions(key: AppDelegate.AblyKey)

    var rest: ARTRest!

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        options.clientId = UIDevice.current.identifierForVendor!.uuidString
        rest = ARTRest(options: options)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.text += "\n" + "AppID: " + (options.key?.prefix(6) ?? "no key")
        textView.text += "\n" + "Env: " + (options.environment.isEmpty ? "production" : options.environment)
        #if DEBUG
        textView.text += "\n" + "Mode: DEBUG"
        #else
        textView.text += "\n" + "Mode: RELEASE"
        #endif
        textView.text += "\n" + "ClientID: " + (options.clientId ?? "nil")
        textView.text += "\n" + "DeviceID: " + rest.device.id
        textView.text += "\n" + "DeviceToken: " + (UserDefaults.standard.string(forKey: "ARTDeviceToken") ?? "nil")
    }

    @IBAction func sendNotificationButtonTapped(_ sender: Any) {
        let message = ARTMessage(name: "experiment", data: "")
        message.extras = [
            "push": [
                "notification": [
                    "title": "Hello from Ably!",
                    "body": "Example push notification from Ably."
                ],
                "data": [
                    "foo": "bar",
                    "baz": "qux"
                ]
            ]
        ] as NSDictionary

        rest.channels.get("groups").publish([message]) { error in
            print("Publish notification:", error ?? "nil")
            DispatchQueue.main.async {
                self.textView.text += "\n" + "Publish notification"
            }
        }
    }

    @IBAction func subscribeClientButtonTapped(_ sender: Any) {
        rest.channels.get("groups").push.subscribeClient() { error in
            let e: String = error?.debugDescription ?? "nil"
            print("Subscribe Client:", error ?? "nil")
            DispatchQueue.main.async {
                self.textView.text += "\n" + "Subscribe Client: \(e)"
            }
        }
    }

    @IBAction func subscribeDeviceButtonTapped(_ sender: Any) {
        rest.channels.get("groups").push.subscribeDevice() { error in
            let e: String = error?.debugDescription ?? "nil"
            print("Subscribe Device:", error ?? "nil")
            DispatchQueue.main.async {
                self.textView.text += "\n" + "Subscribe Device: \(e)"
            }
        }
    }

}
