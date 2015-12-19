//
//  VideoUtility.swift
//  ObservationDiary
//
//  Created by tajika on 2015/11/15.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import AVFoundation

class VideoUtility: MediaUtility {
    
    // MARK: - Properties
    
    let VideoDirectory: String = "/videos"
    var VideoDirectoryPath: String = ""
    
    override init() {
        super.init()
        VideoDirectoryPath = DocumentsDirectory + VideoDirectory
        fileManager.fileExistsAtPath(VideoDirectoryPath, isDirectory: &isDir)
        makeDirectoryIfNeeded(VideoDirectoryPath)
    }
    
    // MARK: - Methods
    func get(fileName: String) -> String? {
        let filePath = VideoDirectoryPath + "/" + fileName
        if fileManager.fileExistsAtPath(filePath) {
            return filePath
        } else {
            return nil
        }
    }
    
    func getFilePath(fileName: String) -> String {
        return VideoDirectoryPath + "/" + fileName
    }
    
    func makeVideoFromTarget(target: TargetData) {
        var photos: [UIImage] = []
        if target.photos.count >= Constants.Video.minPhotos {
            for photo in target.photos {
                let image = PhotoUtility().get(photo.photo)
                photos.append(image!)
            }
            makeVideoFromPhotos(photos, fileName: "\(target.id).\(Constants.Video.VideoExtension)")
        }
    }
    
    func makeVideoFromPhotos(images: [UIImage], fileName: String) {

        // 最初の画像から動画のサイズ指定する
        let size = images[0].size
        
        let VideoPath = VideoDirectoryPath + "/" + fileName
        let TmpVideoPath = VideoDirectoryPath + "/tmp_" + fileName
        
        let videoWriter: AVAssetWriter = try! AVAssetWriter(URL: NSURL(fileURLWithPath: VideoPath), fileType: AVFileTypeMPEG4)
        
        // アウトプットの設定
        let outputSettings: [String: AnyObject] = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]
        
        // writer inputを生成
        let writerInput: AVAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: outputSettings)
        
        // writerにwriter inputを設定
        videoWriter.addInput(writerInput)
        
        // source pixel buffer attributesを設定
        let sourcePixelBufferAttributes: [String: AnyObject] = [
            //kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: size.width,
            kCVPixelBufferHeightKey as String: size.height
        ]
        
        // writer input pixel buffer adaptorを生成
        let adaptor: AVAssetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
        
        writerInput.expectsMediaDataInRealTime = true
        
        if fileManager.fileExistsAtPath(VideoPath) {
            do {
                try fileManager.moveItemAtPath(VideoPath, toPath: TmpVideoPath)
                print("moved")
            } catch {
                print("error: video cannot remove")
            }
        }
        
        // 生成開始できるか確認
        if videoWriter.startWriting() {

            // 動画生成開始
            videoWriter.startSessionAtSourceTime(kCMTimeZero)
            
            assert(adaptor.pixelBufferPool != nil)
            
            let media_queue = dispatch_queue_create("mediaInputQueue", nil)
        
            writerInput.requestMediaDataWhenReadyOnQueue(media_queue, usingBlock: { () -> Void in
                
                // 現在のフレームカウント
                var frameCount: Int = 0
        
                // FPS
                let fps: Int32 = 9
                
                // 各画像の表示する時間
                let frameDuration = CMTimeMake(1, fps)

                // 全画像をバッファに貯めこむ
                for image in images {
                    
                    if !adaptor.assetWriterInput.readyForMoreMediaData {
                        break
                    }
                    
                    if frameCount == Constants.Video.maxPhotos {
                        break
                    }
                        
                    let lastFrameTime = CMTimeMake(Int64(frameCount), fps)
                    let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
            
                    autoreleasepool({ () -> () in
                        // CGImageからバッファを生成（後述）
                        let buffer: CVPixelBufferRef = self.pixelBufferFromCGImage(image.CGImage!, frameSize: size)
                        // 生成したバッファを追加
                        if !adaptor.appendPixelBuffer(buffer, withPresentationTime: presentationTime) {
                            // Error!
                        }
                    })
        
                    frameCount++;
                }
        
                // 動画生成終了
                writerInput.markAsFinished()
                videoWriter.finishWritingWithCompletionHandler({
                    do {
                        try self.fileManager.removeItemAtPath(TmpVideoPath)
                    } catch {
                        print("error: Cannot remove tmp video file")
                    }
                })
            })
        }
    }
    
    func pixelBufferFromCGImage (img: CGImageRef, frameSize: CGSize) -> CVPixelBufferRef {

        let options: [String: AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.alloc(1)

        _ = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), OSType(kCVPixelFormatType_32ARGB), options, pixelBufferPointer)
        
        _ = CVPixelBufferLockBaseAddress(pixelBufferPointer.memory!, 0)
        let pixelData:UnsafeMutablePointer<(Void)> = CVPixelBufferGetBaseAddress(pixelBufferPointer.memory!)
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipFirst.rawValue)
        let space:CGColorSpace = CGColorSpaceCreateDeviceRGB()!
        
        let context:CGContextRef = CGBitmapContextCreate(pixelData, Int(frameSize.width), Int(frameSize.height), 8, CVPixelBufferGetBytesPerRow(pixelBufferPointer.memory!), space, bitmapInfo.rawValue)!
        
        CGContextDrawImage(context, CGRectMake(0, 0, frameSize.width, frameSize.height), img)
        
        CVPixelBufferUnlockBaseAddress(pixelBufferPointer.memory!, 0)
        
        let pixelBuffer = pixelBufferPointer.memory!
        pixelBufferPointer.destroy()
        
        return pixelBuffer
    }
    
    func delete(fileName: String) {
        do {
            try fileManager.removeItemAtPath(VideoDirectoryPath + "/" + fileName)
        } catch {
            print("failed: delete file")
        }
    }
    
}