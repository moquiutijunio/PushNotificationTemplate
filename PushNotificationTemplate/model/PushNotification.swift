//
//  PushNotification.swift
//  PushNotificationTemplate
//
//  Created by Junio Moquiuti on 05/06/19.
//  Copyright © 2019 Junio Moquiuti. All rights reserved.
//

struct PushNotification: Codable {

    var title: String
    var message: String

    enum CodingKeys: String, CodingKey {
        case title = "aps.alert.title"
        case message = "aps.alert.body"
    }
}
