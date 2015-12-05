//
//  CameraViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/31.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: Properties

    var input: AVCaptureDeviceInput!
    var output: AVCaptureVideoDataOutput!
    var session: AVCaptureSession!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayImageView: UIImageView! = UIImageView()
    var camera: AVCaptureDevice!
    var overlayImage: UIImage?
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var previewWidth: CGFloat = 0.0
    var previewHeight: CGFloat = 0.0
    var screenTopMargin: CGFloat = 0.0
    var screenTopMarginRate: CGFloat = 0.16

    override func viewDidLoad() {
        super.viewDidLoad()
             
        // 前回撮影の画像をビューに重ねる
        if overlayImage != nil {
            overlayImageView?.image = overlayImage
        }
        
        UIInterfaceOrientation.Portrait.rawValue

    }

    // メモリ管理のため
    override func viewWillAppear(animated: Bool) {
        // カメラの設定
        setupCamera()
    }
    
    // メモリ管理のため
    override func viewDidDisappear(animated: Bool) {
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        session = nil
        camera = nil
    }
    
    func setupCamera() {
        
        // セッション
        session = AVCaptureSession()
        
        // sessionPreset: キャプチャ・クオリティの設定
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        for captureDevice: AnyObject in AVCaptureDevice.devices() {
            // 背面カメラを取得
            if captureDevice.position == AVCaptureDevicePosition.Back {
                camera = captureDevice as? AVCaptureDevice
            }
            // 前面カメラを取得
            //if caputureDevice.position == AVCaptureDevicePosition.Front {
            //    camera = caputureDevice as? AVCaptureDevice
            //}
        }
        
        // カメラからの入力データ
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        
        // 入力をセッションに追加
        if (session.canAddInput(input)) {
            session.addInput(input)
        }
        
        // 動画出力のインスタンス生成
        output = AVCaptureVideoDataOutput()
        // 出力をセッションに追加
        if (session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // ピクセルフォーマットを 32bit BGR + A とする
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey : Int(kCVPixelFormatType_32BGRA)]
        
        // フレームをキャプチャするためのサブスレッド用のシリアルキューを用意
        output.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
        
        output.alwaysDiscardsLateVideoFrames = true
        
        session.startRunning()

        // deviceをロックして設定
        do {
            try camera.lockForConfiguration()
            // フレームレート
            camera.activeVideoMinFrameDuration = CMTimeMake(1, 15)
            
            camera.unlockForConfiguration()
        } catch {
        }

    }
    
    // 新しいキャプチャの追加で呼ばれる
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        // キャプチャしたsampleBufferからUIImageを作成
        let image: UIImage = self.captureImage(sampleBuffer)
        
        // 画像を画面に表示
        dispatch_async(dispatch_get_main_queue()) {
            let cropImage = self.cropThumbnailImage(image, x: 0.0, y: 0.0, width: image.size.width, height: image.size.width)
            if self.imageView != nil {
                self.imageView.image = cropImage
            }
        }
    }
    
    // sampleBufferからUIImageを作成
    func captureImage(sampleBuffer: CMSampleBufferRef) -> UIImage {
        
        // Sampling Bufferから画像を取得
        let imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // pixel buffer のベースアドレスをロック
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        
        let baseAddress: UnsafeMutablePointer<Void> = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        
        let bytesPerRow: Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width: Int = CVPixelBufferGetWidth(imageBuffer)
        let height: Int = CVPixelBufferGetHeight(imageBuffer)
        
        // 色空間
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        
        let bitsPerCompornent: Int = 8
        // swift 2.0
        let newContext: CGContextRef = CGBitmapContextCreate(baseAddress, width, height, bitsPerCompornent, bytesPerRow, colorSpace,  CGImageAlphaInfo.PremultipliedFirst.rawValue|CGBitmapInfo.ByteOrder32Little.rawValue)!
        
        let imageRef:CGImageRef = CGBitmapContextCreateImage(newContext)!
        let resultImage = UIImage(CGImage: imageRef, scale: 2.0, orientation: UIImageOrientation.Right)

        return resultImage
    }

    @IBAction func takeStillPicture(sender: UIButton) {
        // ビデオ出力に接続.
        if let _: AVCaptureConnection? = output.connectionWithMediaType(AVMediaTypeVideo) {
            // シャッター音
            AudioServicesPlaySystemSound(1108)

            // プレビューのUIImage
            let image: UIImage = self.imageView.image!
            
            // 確認画面へ
            performSegueWithIdentifier("confirmPhoto", sender: image)
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        print("cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cropThumbnailImage(image: UIImage, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage {

        let fixedImage = image.fixOrientation()

        // 切り抜き処理
        let cropRect  = CGRectMake(x, y, width, height)
        let cropRef   = CGImageCreateWithImageInRect(fixedImage.CGImage!, cropRect)
        let cropImage = UIImage(CGImage: cropRef!)
        
        return cropImage
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nav: UINavigationController = segue.destinationViewController as! UINavigationController

        let photoViewController = nav.viewControllers[0] as! PhotoViewController
        // 新規作成の時はsenderがUIImage
        if sender is UIImage {
            if let takenPhoto = sender as? UIImage {
                photoViewController.selectedImage = takenPhoto
            }

        }
    }
    
    //指定方向に自動的に変更するか？
    override func shouldAutorotate() -> Bool{
        return true
    }

}

// 画像が回転される
extension UIImage {
    func fixOrientation () -> UIImage {
        if self.imageOrientation == .Up {
            return self
        }
        var transform = CGAffineTransformIdentity
        let width = self.size.width
        let height = self.size.height
        
        switch (self.imageOrientation) {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, width, height)
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        default: // o.Up, o.UpMirrored:
            break
        }
        
        switch (self.imageOrientation) {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        default: // o.Up, o.Down, o.Left, o.Right
            break
        }
        let cgimage = self.CGImage
        
        let ctx = CGBitmapContextCreate(nil, Int(width), Int(height),
            CGImageGetBitsPerComponent(cgimage), 0,
            CGImageGetColorSpace(cgimage),
            CGImageGetBitmapInfo(cgimage).rawValue)
        
        CGContextConcatCTM(ctx, transform)
        
        switch (self.imageOrientation) {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, height, width), cgimage)
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), cgimage)
        }
        let cgimg = CGBitmapContextCreateImage(ctx)
        let img = UIImage(CGImage: cgimg!)
        return img
    }
}
