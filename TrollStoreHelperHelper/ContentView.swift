// bomberfish
// ContentView.swift – TrollStoreHelperHelper
// created on 2023-11-27

import SwiftUI

struct ContentView: View {
    @State var tipsURL: URL? = nil
    @State var helperURL: URL? = nil
    var body: some View {
        NavigationStack {
            List {
                Section(content: {
                    Button(action: {
                        if tipsURL == nil || helperURL == nil {
                            Haptic.shared.notify(.error)
                            UIApplication.shared.alert(body: "bruh")
                        } else {
                            Haptic.shared.play(.soft)
                            do {
                                let origsize: Int = try Data(contentsOf: tipsURL!.appendingPathComponent("Tips.app").appendingPathComponent("Tips")).count
                                try MDC.overwriteFile(at: tipsURL!.appendingPathComponent("Tips.app").appendingPathComponent("Tips").path, with: .init(count: origsize)) // megajank
                                try MDC.overwriteFile(at: tipsURL!.appendingPathComponent("Tips.app").appendingPathComponent("Tips").path, with: .init(contentsOf: helperURL!))
                                let helpercontents = try Data(contentsOf: helperURL!)
                                let tipscontents = try Data(contentsOf: tipsURL!.appendingPathComponent("Tips.app").appendingPathComponent("Tips"))
                                print(tipscontents == helpercontents)
                                print(tipscontents.contains(helpercontents))
                                UIApplication.shared.alert(title: "Success!", body: "Please reboot your device and open the Tips app.")
                            } catch {
                                UIApplication.shared.alert(body: error.localizedDescription)
                            }
                        }
                    }, label: {
                        Label("Murder Tips.app", systemImage: "lightbulb")
                    })
                }, header: { Label("Make it So", systemImage: "arrow.right") }, footer: {
                    VStack {
                        Label("By BomberFish\nVery much in-development. Don't complain if shit breaks.", systemImage: "info")
                    }
                })
//                Section(content: {}, footer: {
//                    if tipsURL != nil {
//                        Label("Detected Tips.app: \(tipsURL?.appendingPathComponent("Tips.app").path ?? "None")", systemImage: "info")
//                    }
//                })
//                Section(content: {}, footer: {
//                    if helperURL != nil {
//                        Label("Detected PersistenceHelper: \(helperURL?.path ?? "None")", systemImage: "info")
//                    }
//                })
            }
            .navigationTitle("TrollStoreHelperHelper")
            .onAppear {
                UIApplication.shared.alert(title: "Loading", body: "Not praying to RNGesus", withButton: false)
                helperURL = Bundle.main.url(forResource: "PersistenceHelper_Embedded", withExtension: nil)
                sleep(1)
                grant_full_disk_access { error in
                    if error != nil {
                        Haptic.shared.notify(.error)
                        UIApplication.shared.changeTitle("Access Error")
                        UIApplication.shared.changeBody("Error: \(String(describing: error?.localizedDescription))\nPlease close the app and retry.")
                    } else {
                        Haptic.shared.notify(.success)
                        do {
                            sleep(1)
                            UIApplication.shared.changeBody("Finding victim...")
                            tipsURL = try getBundleDir(bundleID: "com.apple.tips")
                            sleep(1)
                            UIApplication.shared.dismissAlert(animated: true)
                        } catch {
                            UIApplication.shared.changeTitle("Access Error")
                            UIApplication.shared.changeBody("Error: \(error.localizedDescription)\nPlease close the app and retry.")
                        }
                    }
                }
                if tipsURL != nil {
                    print(FileManager.default.fileExists(atPath: tipsURL!.appendingPathComponent("Tips.app").path))
                }
            }
        }
    }
}

// practically stolen from appcommander.
public func getBundleDir(bundleID: String) throws -> URL {
    let fm = FileManager.default
    var returnedurl = URL(string: "none")
    var dirlist = [""]

    do {
        dirlist = try fm.contentsOfDirectory(atPath: "/var/containers/Bundle/Application")
        // print(dirlist)
    } catch {
        throw "Could not access /var/containers/Bundle/Application.\n\(error.localizedDescription)"
    }

    for dir in dirlist {
        // print(dir)
        let mmpath = "/var/containers/Bundle/Application/" + dir + "/.com.apple.mobile_container_manager.metadata.plist"
        // print(mmpath)
        do {
            var mmDict: [String: Any]
            if fm.fileExists(atPath: mmpath) {
                mmDict = try PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: mmpath)), options: [], format: nil) as? [String: Any] ?? [:]

                // print(mmDict as Any)
                if mmDict["MCMMetadataIdentifier"] as! String == bundleID {
                    returnedurl = URL(fileURLWithPath: "/var/containers/Bundle/Application").appendingPathComponent(dir)
                }
            } else {
                print("WARNING: Directory \(dir) does not have a metadata plist")
            }
        } catch {
            print("Could not get data of \(mmpath): \(error.localizedDescription)")
            throw ("Could not get data of \(mmpath): \(error.localizedDescription)")
        }
    }
    if returnedurl != URL(string: "none") {
        return returnedurl!
    } else {
        throw "App \(bundleID) cannot be found, is a system app, or is not installed."
    }
}
