//
//  VideoManager.swift
//  PhotoLogger
//
//  Created by tajika on 2015/11/15.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import AVFoundation

class VideoManager {
    
    // MARK: Properties
    
    let DocumentsDirectory: String
    let VideoDirectory: String = "/videos"
    let VideoDirectoryPath: String
    var isDir: ObjCBool = false
    let fileManager = NSFileManager.defaultManager()
    let now = NSDate()
    let formatter = NSDateFormatter()
    
    init() {
        DocumentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        VideoDirectoryPath = DocumentsDirectory + VideoDirectory
        fileManager.fileExistsAtPath(VideoDirectoryPath, isDirectory: &isDir)
        
        //ディレクトリが存在しない場合に、ディレクトリを作成する
        if !isDir {
            do {
                try fileManager.createDirectoryAtPath(VideoDirectoryPath ,withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("error: cannot create directory")
            }
        }
    }
    
    // MARK: Methods
    func get(fileName: String) -> String? {
        let filePath = VideoDirectoryPath + "/" + fileName
        if fileManager.fileExistsAtPath(filePath) {
            return filePath
        } else {
            return nil
        }
    }
    
    func insert(image: UIImage) -> String? {
        
        let jpegData = UIImageJPEGRepresentation(image, 1.0)!
        
        // ファイル名を指定して保存
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = formatter.stringFromDate(now) + ".mp4"
        let filePath = VideoDirectoryPath + "/" + fileName
        jpegData.writeToFile(filePath, atomically: true)
        
        return fileName
    }
    
    func makeVideoFromPhotos(images: [UIImage], fileName: String) {
        // 最初の画像から動画のサイズ指定する
        let size = images[0].size
        
        let VideoPath = VideoDirectoryPath + "/" + fileName + ".mp4"
        
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
                try fileManager.removeItemAtPath(VideoPath)
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
                let fps: Int32 = 12
                
                // 各画像の表示する時間
                let frameDuration = CMTimeMake(1, fps)

                // 全画像をバッファに貯めこむ
                for image in images {
                    if !adaptor.assetWriterInput.readyForMoreMediaData {
                        break
                    }
                
                    // 動画の時間を生成（その画像の表示する時間。開始時点と表示時間を渡す）
                    //let frameTime: CMTime = CMTimeMake(Int64(frameCount) * Int64(fps) * Int64(durationForEachImage), fps);
                    
                    let lastFrameTime = CMTimeMake(Int64(frameCount), fps)
                    let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
            
                    // CGImageからバッファを生成（後述）
                    let buffer: CVPixelBufferRef = self.pixelBufferFromCGImage(image.CGImage!, frameSize: size)
            
                    // 生成したバッファを追加
                    if !adaptor.appendPixelBuffer(buffer, withPresentationTime: presentationTime) {
                        // Error!
                    }
            
                    frameCount++;
                }
        
                // 動画生成終了
                writerInput.markAsFinished()
                //videoWriter.endSessionAtSourceTime(CMTimeMake(Int64(frameCount - 1) * Int64(fps) * Int64(durationForEachImage), fps))
        
                videoWriter.finishWritingWithCompletionHandler({
                    while true {
                        if videoWriter.status == .Completed {
                            UISaveVideoAtPathToSavedPhotosAlbum(VideoPath, self, nil, nil)
                            break
                        }
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
        
        return pixelBufferPointer.memory!
    }
    
    func delete(fileName: String) {
        do {
            try fileManager.removeItemAtPath(VideoDirectoryPath + "/" + fileName)
        } catch {
            print("failed: delete file")
        }
    }
    
}