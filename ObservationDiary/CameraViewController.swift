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

    // MARK: - Properties

    var input: AVCaptureDeviceInput!
    var output: AVCaptureVideoDataOutput!
    var session: AVCaptureSession!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayImageView: UIImageView! = UIImageView()
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var cameraGrid: UIImageView!
    var camera: AVCaptureDevice?
    var overlayImage: UIImage?
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var previewWidth: CGFloat = 0.0
    var previewHeight: CGFloat = 0.0
    var screenTopMargin: CGFloat = 0.0
    var screenTopMarginRate: CGFloat = 0.16

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Constants.Theme.gray()
    
        // 前回撮影の画像をビューに重ねる
        if overlayImage != nil {
            overlayImageView?.image = overlayImage
        }
        
        UIInterfaceOrientation.Portrait.rawValue

    }

    override func viewWillAppear(animated: Bool) {
        // カメラの設定
        setupCamera()
    }
    
    // メモリ管理のため
    override func viewDidDisappear(animated: Bool) {
        if let session = self.session {
            // camera stop メモリ解放
            session.stopRunning()
            
            for output in session.outputs {
                session.removeOutput(output as? AVCaptureOutput)
            }
            
            for input in session.inputs {
                session.removeInput(input as? AVCaptureInput)
            }
            self.session = nil
            self.camera = nil
        }
    }
    
    // ステータスバー隠す
    override func prefersStatusBarHidden() -> Bool {
        return true
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
        
        guard let camera = camera else {
            noCamera()
            return
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
            let cropImage = image.cropThumbnailImage(x: 0.0, y: 0.0, width: image.size.width, height: image.size.width)
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
        
        if isSimulator() {
            simulatorBehaviorTakePicture()
        } else {
            // ビデオ出力に接続.
            if let _: AVCaptureConnection = output.connectionWithMediaType(AVMediaTypeVideo) {
                // シャッター音
                AudioServicesPlaySystemSound(1108)

                // プレビューのUIImage
                let image: UIImage = self.imageView.image!
                
                // 確認画面へ
                performSegueWithIdentifier("confirmPhoto", sender: image)
            }
        }
    }
    
    @IBAction func alphaChaging(sender: AlphaControlSlider) {
        overlayImageView.alpha = CGFloat(sender.value)
    }

    @IBAction func switchGridDisplay(sender: UIButton) {
        cameraGrid.alpha = sender.selected ? 1 : 0
        sender.selected = !sender.selected
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        print("cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pinchForZoom(sender: UIPinchGestureRecognizer) {
        if let device: AVCaptureDevice = self.camera {
            let vZoomFactor = sender.scale
            do {
                try device.lockForConfiguration()
                defer {
                    device.unlockForConfiguration()
                }
                if vZoomFactor <= device.activeFormat.videoMaxZoomFactor {
                    device.videoZoomFactor = vZoomFactor
                }
            } catch _ {
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func noCamera() {
        if isSimulator() {
            if let image: UIImage = R.image.buttonGreen() {
                self.imageView.image = image
            }
        } else {
            takeButton.enabled = false
        }
        return
    }
    
    func simulatorBehaviorTakePicture() {
        if isSimulator() {
            if let image: UIImage = R.image.buttonGreen() {
                // 適当な画像で確認画面へ
                performSegueWithIdentifier("confirmPhoto", sender: image)
            }
        }
        return
    }
    
    private func isSimulator() -> Bool {
        return TARGET_OS_SIMULATOR != 0
    }

}
