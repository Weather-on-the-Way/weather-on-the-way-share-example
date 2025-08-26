//
//  ContentView.swift
//  ShareWithWeatherOnTheWayExample
//
//  Created by Weather on the Way on 26/08/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State var fileImporterShowing = false

    @State var fileName: String?
    @State var gpxData: Data?

    var fileLabel: String {
        if let fileURL = fileName {
            return fileURL
        } else {
            return "File not loaded"
        }
    }

    func loadFile(_ url: URL) {
        // Access security scoped resource
        let isSecured = url.startAccessingSecurityScopedResource()

        // load file data
        if let data = try? Data(contentsOf: url) {
            self.gpxData = data
            self.fileName = url.lastPathComponent
        }

        if isSecured {
            url.stopAccessingSecurityScopedResource()
        }

    }

    func openWeatherOnTheWay() {
        // get loaded file data
        if let gpxData = gpxData {

            let dataEncoded = gpxData.base64EncodedString()

            let urlString = "weatherontheway://gpx-data/".appending(dataEncoded)

            if let url = URL(string: urlString) {

                // Make sure to add following record to your Info.plist file
                /*

                 <key>LSApplicationQueriesSchemes</key>
                 <array>
                 <string>weatherontheway</string>
                 </array>

                 */

                // Check if Weather on the Way is installed
                if UIApplication.shared.canOpenURL(url) {
                    // open GPX data
                    UIApplication.shared.open(url)
                } else {
                    // open AppStore to download Weather on the Way
                    UIApplication.shared.open(URL(string: "https://get.weatherontheway.app/gpx-import")!)
                }
            }

        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Button("Select GPX file") {
                fileImporterShowing = true
            }

            Text(fileLabel)

            Button("Open in Weather on the Way") {
                openWeatherOnTheWay()
            }

            Spacer()
        }
        .fileImporter(isPresented: $fileImporterShowing, allowedContentTypes: UTType.types(tag: "gpx", tagClass: .filenameExtension, conformingTo: nil)) { result in
            switch result {
            case .success(let url):
                loadFile(url)
            case .failure(let error):
                print("Can't load file", error)
            }
        }
    }
}

#Preview {
    ContentView()
}
