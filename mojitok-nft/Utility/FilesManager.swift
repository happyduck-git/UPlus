//
//  FilesManager.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/16.
//

import Foundation

public final class FilesManager {
    
    public static let rootDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    public static let mojitokUIKitFolderURL = rootDirectoryURL.appendingPathComponent("MojitokNFT", isDirectory: true)
    public static let cacheFolderURL = mojitokUIKitFolderURL.appendingPathComponent("Cache", isDirectory: true)
    
    public static func saveImage(url: URL, data: Data) {
        do {
            try data.write(to: url)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public static func dataToFile(at url: URL, data: Data) {
        do {
            try data.write(to: url)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public static func removeFile(url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    public static func createDirectory(at url: URL) {
        guard !FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public static func existDirectory(at url: URL) -> Bool {
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            return isDir.boolValue
        } else {
            return false
        }
    }
    
    public static func checkDirectory(url: URL) {
        if !existDirectory(at: url) {
            createDirectory(at: url)
        }
    }
}
