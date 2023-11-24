//
//  ImageRenderer.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/03/16.
//

import UIKit

final class ImageRenderer {
    private static let jpegCompressionQuality = 0.75
    private static let stableFrameRect = CGRect(origin: .zero, size: .init(width: 720, height: 720))
    static let shared = ImageRenderer()
    
    private init() {
    }
    
    private func getStoringLayerProperties(_ layer: CALayer) -> (CGRect, CGColor?, CGFloat, Bool) {
        return (layer.frame, layer.backgroundColor, layer.cornerRadius, layer.drawsAsynchronously)
    }
    
    private func setRestoringLayerProperties(
        _ layer: CALayer,
        properties: (frame: CGRect, backgroundColor: CGColor?, cornerRadius: CGFloat, drawsAsynchronously: Bool)
    ) {
        layer.frame = properties.frame
        layer.backgroundColor = properties.backgroundColor
        layer.cornerRadius = properties.cornerRadius
        layer.drawsAsynchronously = properties.drawsAsynchronously
    }
    
    private func setLayerForImageRenderingTask(_ layer: CALayer) {
        layer.frame = ImageRenderer.stableFrameRect
        layer.backgroundColor = UIColor.bg.cgColor
        layer.cornerRadius = 0
        layer.drawsAsynchronously = true
    }
    
    func renderImages(animationView: AnimationView) -> [Int: Data] {
        guard let animation = animationView.animation else {
            LLog.w("animation is nil.")
            return [:]
        }
        
        let framesLength = Int(animation.endFrame) + 1
        var imageDictionary: [Int: Data] = [:]
        let imageDictionaryLock = NSLock()
        
        imageDictionary.reserveCapacity(framesLength)
        
        var originalProperties: (CGRect, CGColor?, CGFloat, Bool)?
        DispatchQueue.main.async {
            let layer = animationView.layer
            originalProperties = self.getStoringLayerProperties(layer)
            self.setLayerForImageRenderingTask(layer)
        }
        
        let taskGroup = DispatchGroup()
        taskGroup.enter()
        
        for frameIndex in 0..<framesLength {
            let subTaskGroup = DispatchGroup()
            subTaskGroup.enter()
            
            DispatchQueue.main.async {
                animationView.updateAnimationFrame(CGFloat(frameIndex))
                let layer = animationView.layer
                
                let finishLayerRenderingTaskHandler = {
                    subTaskGroup.leave()
                }
                
                self.renderImageAsync(layer: layer, finishLayerRenderingTaskHandler: finishLayerRenderingTaskHandler) { imageData in
                    imageDictionaryLock.lock()
                    imageDictionary[frameIndex] = imageData
                    
                    if imageDictionary.count >= framesLength {
                        taskGroup.leave()
                    }
                    imageDictionaryLock.unlock()
                }
            }
            
            subTaskGroup.wait()
        }
        
        taskGroup.wait()
        
        if let originalProperties = originalProperties {
            DispatchQueue.main.async {
                let layer = animationView.layer
                self.setRestoringLayerProperties(layer, properties: originalProperties)
            }
        } else {
            LLog.w("originalProperties is nil.")
        }
        
        return imageDictionary
    }
    
    private func renderImageAsync(
        layer: CALayer,
        finishLayerRenderingTaskHandler: @escaping () -> Void,
        resultImageHandler: @escaping (Data?) -> Void
    ) {
        DispatchQueue.global().async {
            let imageRendererFormat = UIGraphicsImageRendererFormat()
            imageRendererFormat.scale = 1.0
            let renderer = UIGraphicsImageRenderer(bounds: ImageRenderer.stableFrameRect, format: imageRendererFormat)
            
            let imageData = renderer.jpegData(withCompressionQuality: ImageRenderer.jpegCompressionQuality) { rendererContext in
                let layerTaskGroup = DispatchGroup()
                layerTaskGroup.enter()
                
                DispatchQueue.main.async(group: layerTaskGroup) {
                    layer.render(in: rendererContext.cgContext)
                    finishLayerRenderingTaskHandler()
                    layerTaskGroup.leave()
                }
                layerTaskGroup.wait()
            }
            resultImageHandler(imageData)
        }
    }
    
    @available(*, deprecated)
    func quickRenderImage(layer: CALayer, size: CGSize, completion: @escaping ((Data?) -> Void)) {
        let queue = DispatchQueue(label: "ImageRenderer", qos: .background, attributes: .concurrent)
        
        let rect = CGRect(origin: .zero, size: size)
//        queue.async {
            layer.frame = rect
            layer.backgroundColor = UIColor.bg.cgColor
            layer.cornerRadius = 0
            layer.drawsAsynchronously = true
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            let renderer: UIGraphicsImageRenderer? = UIGraphicsImageRenderer(bounds: rect, format: format)
        let data = renderer!.jpegData(withCompressionQuality: ImageRenderer.jpegCompressionQuality) { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        queue.async {
            completion(data)
        }
    }
}
