//
//  FontService.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/03/28.
//

import UIKit

final class FontService {
    
    static let fontFolderURL = FilesManager.cacheFolderURL.appendingPathComponent("font", isDirectory: true)
    static let fontFileURL = fontFolderURL.appendingPathComponent("Font.txt")
    static let shared: FontService = .init()
    
    private(set) var fonts: [FontMeta] = []
    private let queue = DispatchQueue(label: "FontService", qos: .background ,attributes: .concurrent)
    private let fontQueue = DispatchQueue(label: "FontService-Font")
    private let group = DispatchGroup()
    
    private init() {
        FilesManager.checkDirectory(url: FontService.fontFolderURL)
        fonts = fetchFonts()
        syncRemoteConfig()
    }
    
    private func fetchFonts() -> [FontMeta] {
        fontQueue.sync {
            if let data = try? Data(contentsOf: FontService.fontFileURL),
               let fonts = try? JSONDecoder().decode([FontMeta].self, from: data) {
                return fonts
            }
            return []
        }
    }
    
    private func saveFonts() {
        fontQueue.sync {
            if let data = try? JSONEncoder().encode(fonts) {
                try? data.write(to: FontService.fontFileURL)
            }
        }
    }
    
    private func syncRemoteConfig() {
        RemoteConfigService.shared.getResource(key: .fonts) { [weak self] data in
            if let data = data,
               let fonts = try? JSONDecoder().decode([FontMeta].self, from: data) {
                print("📑 RemoteConfig: ✅ Font Success")
                self?.downloadFonts(remoteFonts: fonts)
            } else {
                print("📑 RemoteConfig: ❌ Font Fail")
            }
        }
    }
    
    private func downloadFonts(remoteFonts: [FontMeta]) {
        for font in fonts {
            if !remoteFonts.contains(font) {
                queue.sync {
                    removeFont(font: font)
                }
            }
        }
        for remoteFont in remoteFonts {
            if !fonts.contains(where: { $0.name == remoteFont.name && $0.version == remoteFont.version }) {
                print("download... \(remoteFont.name)")
                queue.async(group: group) { [weak self] in
                    let fileSemaphore = DispatchSemaphore(value: 0)
                    var fileData: Data?
                    self?.removeFont(font: remoteFont)
                    FirebaseStorageService.shared.getFile(urlString: "/fonts/\(remoteFont.name)") { data in
                        fileData = data
                        fileSemaphore.signal()
                    }
                    fileSemaphore.wait()
                    if let fileData = fileData {
                        self?.addFont(font: remoteFont, fileData: fileData)
                    }
                }
            }
        }
        
        group.notify(queue: queue) { [weak self] in
            self?.saveFonts()
            self?.installFonts()
        }
    }
    
    private func addFont(font: FontMeta, fileData: Data) {
        try? fileData.write(to: font.fileURL)
        fontQueue.sync {
            fonts.append(font)
        }
    }
    
    private func removeFont(font: FontMeta) {
        let fontFileURL = FontService.fontFolderURL.appendingPathComponent(font.name)
        FilesManager.removeFile(url: fontFileURL)
        if let index = fonts.firstIndex(of: font) {
            fonts.remove(at: index)
        }
    }
    
    private func installFonts() {
        for font in fonts {
            guard let fontData = NSData(contentsOf: font.fileURL),
                let dataProvider = CGDataProvider(data: fontData),
                let cgFont = CGFont(dataProvider) else {
                return
            }
            var errRef: Unmanaged<CFError>?
            if CTFontManagerRegisterGraphicsFont(cgFont, &errRef) == false {
                print("📝 Font: ❌ Install fail: \(font.name) - \(String(describing: errRef))")
            }
        }
        print("📝 Font: ✅ Install success")
    }
}
