//
//  DailySproutApp.swift
//  DailySprout
//
//  Created by Alvin Reyvaldo on 02/08/25.
//

import SwiftUI

@main
struct DailySproutApp: App {
    init() {
        NotificationManager.shared.checkNotificationStatus()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
