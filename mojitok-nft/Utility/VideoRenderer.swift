//
//  VideoRenderer.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/03/21.
//

import UIKit
import AVFoundation

final class VideoRenderer {
    
    static let shared = VideoRenderer()
    
    private init() {}
    
    func renderVideo(animationView: AnimationView, dic: [String: String], imageData: Data, collectionImageData: Data, completion: @escaping (((Data, Data)?) -> Void)) {
        print("Video Start: \(Date().timeIntervalSince1970)")
        DispatchQueue.main.async {
            guard let videoURL = Bundle.main.url(forResource: "720", withExtension: "mov") else { return }
            let outputURL = FilesManager.cacheFolderURL.appendingPathComponent("template.mov")
            
            FilesManager.removeFile(url: outputURL)
            
            let videoAsset = AVAsset(url: videoURL)
            let assetVideoTrack = videoAsset.tracks(withMediaType: .video).first!
            
            let endTime = CMTime(value: .init(animationView.animation!.endFrame), timescale: .init(animationView.animation!.framerate))
            
            let assetRange = CMTimeRangeMake(start: .zero, duration: endTime)
            
            let composition = AVMutableComposition()
            let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            do {
                try compositionVideoTrack?.insertTimeRange(assetRange, of: assetVideoTrack, at: .zero)
            } catch {
                fatalError("Video Insert Error - \(error.localizedDescription)")
            }
            
            let compositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
            let assetScale = self.scaleFactor(for: assetVideoTrack)
            
            let assetScaleTransform = CGAffineTransform(scaleX: assetScale.width, y: assetScale.height)
            
            var assetTransform = assetVideoTrack.preferredTransform
            if self.isAssetTrackPortrait(assetVideoTrack) {
                let translateTransform = assetScaleTransform.translatedBy(x: assetVideoTrack.naturalSize.height, y: 0)
                assetTransform = translateTransform.rotated(by: .pi / 2)
            }
            
            compositionLayerInstruction.setTransform(assetTransform, at: .zero)
            compositionLayerInstruction.setOpacity(0, at: endTime)
            
            let compositionInstruction = AVMutableVideoCompositionInstruction()
            compositionInstruction.timeRange = assetRange
            compositionInstruction.layerInstructions = [compositionLayerInstruction]
            
            let videoComposition = AVMutableVideoComposition()
            let videoRenderSize = self.renderSize(for: [assetVideoTrack])
            
            videoComposition.renderSize = videoRenderSize
            videoComposition.instructions = [compositionInstruction]
            
            videoComposition.frameDuration = CMTimeMake(value: 1, timescale: .init(120))
            
            // Lottie
            let videoReact: CGRect = .init(x: 0, y: 0, width: 720, height: 720)
            let parentLayer = CALayer()
            let videoLayer = CALayer()
            let scaleLayer = CALayer()
            videoLayer.frame = videoReact
            
            parentLayer.isGeometryFlipped = true
            parentLayer.frame = videoReact
            
            let viewWidth: CGFloat = animationView.bounds.width
            
            scaleLayer.anchorPoint = .init(x: 0, y: 0)
            scaleLayer.frame = .init(origin: .zero, size: CGSize(width: viewWidth, height: viewWidth))

            scaleLayer.addSublayer(animationView.layer)
            let scalev = videoReact.width / viewWidth
            scaleLayer.frame = .init(origin: .init(x: -10 * scalev * scale, y: -122 * scalev * scale), size: animationView.bounds.size)
            
            scaleLayer.transform = CATransform3DMakeScale(scalev, scalev, 1)
            parentLayer.addSublayer(scaleLayer)
            
            animationView.stop()
            animationView.play()
            
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
            
            guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else { return }
            exporter.outputURL = outputURL
            exporter.outputFileType = .mov
            exporter.shouldOptimizeForNetworkUse = false
            exporter.videoComposition = videoComposition
            print("Video End: \(Date().timeIntervalSince1970)")
            exporter.exportAsynchronously {
                print("Start: \(Date().timeIntervalSince1970)")
                ImageRenderer.shared.quickRenderImage(layer: animationView.layer, size: .init(width: 200, height: 200)) { imageData in
                    print("End: \(Date().timeIntervalSince1970)")
                    if let imageData = imageData,
                       let videoData = try? Data(contentsOf: outputURL) {
                        completion((imageData, videoData))
                    }
                }
            }
        }
    }
    
    private func updateImage(view: AnimationView, key: String, data: Data) {
        let base64 = "data:image/png;base64," + data.base64EncodedString()
        view.animation?.assetLibrary?.imageAssets[key]?.name = base64
        view.animation?.assetLibrary?.imageAssets[key]?.directory = ""
    }


    private func updateText(view: AnimationView, _ dic: [String: String]) {
        let textProvider = DictionaryTextProvider(dic)
        view.textProvider = textProvider
    }
    
    func scaleFactor(for assetTrack: AVAssetTrack) -> CGSize {
        let mainBounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        let nativeBounds = UIScreen.main.nativeBounds
        let naturalSize = assetTrack.naturalSize
        
        if !isAssetTrackPortrait(assetTrack) {
            if naturalSize.width > nativeBounds.width && naturalSize.height > nativeBounds.height {
                return CGSize(width: 1.0, height: 1.0)
            }
            
            let widthRatio = mainBounds.width / naturalSize.width
            let heightRatio = mainBounds.height / naturalSize.height
            
            return CGSize(width: min(widthRatio, heightRatio), height: min(widthRatio, heightRatio))
        } else {
            if naturalSize.width > nativeBounds.height && naturalSize.height > nativeBounds.width {
                return CGSize(width: 1.0, height: 1.0)
            }
            
            let widthRatio = nativeBounds.height / naturalSize.width
            let heightRatio = nativeBounds.width / naturalSize.height
            
            return CGSize(width: min(widthRatio, heightRatio), height: min(widthRatio, heightRatio))
        }
    }
    
    func isAssetTrackPortrait(_ assetTrack: AVAssetTrack) -> Bool {
        let trackTransform = assetTrack.preferredTransform
        
        if trackTransform.a == 0 && trackTransform.b == 1.0 && trackTransform.c == -1.0 && trackTransform.d == 0 {
            return true
        }
        if trackTransform.a == 0 && trackTransform.b == -1.0 && trackTransform.c == 1.0 && trackTransform.d == 0 {
            return true
        }
        if trackTransform.a == 1.0 && trackTransform.b == 0 && trackTransform.c == 0 && trackTransform.d == 1.0 {
            return false
        }
        if trackTransform.a == -1.0 && trackTransform.b == 0 && trackTransform.c == 0 && trackTransform.d == -1.0 {
            return false
        }
        
        return true
    }
    
    func renderSize(for assetTracks: [AVAssetTrack]) -> CGSize {
        var renderWidth: CGFloat = 0
        var renderHeight: CGFloat = 0
        
        for assetTrack in assetTracks {
            let naturalSize = assetTrack.naturalSize
            
            if isAssetTrackPortrait(assetTrack) {
                renderWidth = max(renderWidth, naturalSize.height)
                renderHeight = max(renderHeight, naturalSize.width)
            } else {
                renderWidth = max(renderWidth, naturalSize.width)
                renderHeight = max(renderHeight, naturalSize.height)
            }
        }
        
        return CGSize(width: renderWidth, height: renderHeight)
    }
}
