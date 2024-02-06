//
//  ARCamRecordApp.swift
//  ARCamRecord
//
//  Created by Елена Белова on 28/07/2023.
//

import SwiftUI
import Sentry


@main
struct ARCamRecordApp: App {
    init() {
        SentrySDK.start { options in
            options.dsn = "https://e47b28d018525860829ab1106912b5c2@o1062861.ingest.sentry.io/4506699636670464"
            options.debug = true // Enabled debug when first installing is always helpful
            options.enableTracing = true 

            // Uncomment the following lines to add more data to your events
            options.attachScreenshot = true // This adds a screenshot to the error events
            options.attachViewHierarchy = true // This adds the view hierarchy to the error events
           
            options.enableMetricKit = true
            options.enableTimeToFullDisplayTracing = true
            options.swiftAsyncStacktraces = true
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ARManager.shared)
        }
    }
}
