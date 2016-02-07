//
//  CameraViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/31.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    // MARK: - Properties

    var input: AVCaptureDeviceInput!
    var output: AVCaptureStillImageOutput!
    var session: AVCaptureSession!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayImageView: UIImageView! = UIImageView()
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var cameraGrid: UIImageView!
    @IBOutlet weak var alphaControlSlider: AlphaControlSlider!
    var camera: AVCaptureDevice?
    var overlayImage: UIImage?
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var previewWidth: CGFloat = 0.0
    var previewHeight: CGFloat = 0.0
    var screenTopMargin: CGFloat = 0.0
    var screenTopMarginRate: CGFloat = 0.16
    var currentScale: CGFloat = 1.0
    var startScale: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Constants.Theme.gray
        self.imageView.clipsToBounds = true
        
        // 前回撮影の画像をビューに重ねる
        if overlayImage != nil {
            overlayImageView?.image = overlayImage
        } else {
            alphaControlSlider.enabled = false
            alphaControlSlider.hidden = true
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
        output = AVCaptureStillImageOutput()
        output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]

        // 出力をセッションに追加
        if (session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // 画像を表示するレイヤーを生成.
        let capVideoLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        capVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        capVideoLayer.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.width)

        // Viewに追加.
        self.imageView.layer.addSublayer(capVideoLayer)
        
        session.startRunning()

    }

    @IBAction func takeStillPicture(sender: UIButton) {
        
        if isSimulator() {
            simulatorBehaviorTakePicture()
        } else {
            
            // ビデオ出力に接続.
            if let videoConnection: AVCaptureConnection = output.connectionWithMediaType(AVMediaTypeVideo) {
                
                // 接続から画像を取得する
                self.output.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
                    
                    // Jpegに変換する (NSDataにはExifなどのメタデータも含まれている)
                    let imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
                    
                    // UIIMageを作成する
                    let image: UIImage = UIImage(data: imageData)!
                    
                    let y = (image.size.height / 2) - (image.size.width / 2)
                    let cropImage = image.cropThumbnailImage(x: 0.0, y: y, width: image.size.width, height: image.size.width)

                    // シャッター音
                    AudioServicesPlaySystemSound(1108)
                    
                    // 確認画面へ
                    self.performSegueWithIdentifier("confirmPhoto", sender: cropImage)
                    
                })
                
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pinchForZoom(sender: UIPinchGestureRecognizer) {
        if let device: AVCaptureDevice = self.camera {
            let state = sender.state
            do {
                try device.lockForConfiguration()
                defer {
                    device.unlockForConfiguration()
                }
                let vZoomFactor = sender.scale
                if vZoomFactor <= device.activeFormat.videoMaxZoomFactor {
                    if vZoomFactor < 1.0 {
                        if state == .Began {
                            currentScale = currentScale - (1.0 - vZoomFactor)
                            startScale = currentScale
                        } else {
                            currentScale = startScale - (1.0 - vZoomFactor) * 4
                        }
                    } else {
                        if state == .Began {
                            currentScale = currentScale + (vZoomFactor - 1.0)
                            startScale = currentScale
                        } else {
                            currentScale = startScale + (vZoomFactor - 1.0)
                        }
                    }
                    if currentScale > 5.0 {
                        currentScale = 5.0
                    } else if currentScale < 1.0 {
                        currentScale = 1.0
                    }
                    if state == .Began {
                        startScale = currentScale
                    }
                    device.videoZoomFactor = currentScale
                }
            } catch let error {
                print(error)
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
