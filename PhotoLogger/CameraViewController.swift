//
//  CameraViewController.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/31.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    // MARK: Properties

    var input: AVCaptureDeviceInput!
    var output: AVCaptureStillImageOutput!
    var session: AVCaptureSession!
    var preView: UIView!
    var camera: AVCaptureDevice!
    var overlayImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // メモリ管理のため
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = UIColor.lightGrayColor()
        // スクリーン設定
        setupDisplay()
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
    
    func setupDisplay(){
        //スクリーンの幅
        let screenWidth = UIScreen.mainScreen().bounds.size.width;
        //スクリーンの高さ
        let screenHeight = screenWidth;
        
        // プレビュー用のビューを生成
        preView = UIView(frame: CGRectMake(0.0, 60.0, screenWidth, screenHeight))
        
    }
    
    func setupCamera(){
        
        // セッション
        session = AVCaptureSession()
        
        for caputureDevice: AnyObject in AVCaptureDevice.devices() {
            // 背面カメラを取得
            if caputureDevice.position == AVCaptureDevicePosition.Back {
                camera = caputureDevice as? AVCaptureDevice
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
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        // 静止画出力のインスタンス生成
        output = AVCaptureStillImageOutput()
        // 出力をセッションに追加
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // セッションからプレビューを表示を
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.frame = preView.frame
        
        // previewLayer.videoGravity = AVLayerVideoGravityResize
        // previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // レイヤーをViewに設定
        self.view.layer.addSublayer(previewLayer)
        

        // プレビューにオーバーレイするビューを作成
        // let overlayView = UINib(nibName: "CameraOverlayView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! UIView
        // let imageView = overlayView.viewWithTag(1) as! UIImageView
        let overlayView = UIView(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        
        self.view.addSubview(overlayView)
        
        // 前回撮影の画像をビューに重ねる
        if overlayImage != nil {
            let imageView = UIImageView(frame: CGRectMake(0.0, 60.0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width))
        
            imageView.image = overlayImage
            imageView.alpha = 0.3
            
            overlayView.addSubview(imageView)
        }
        // 撮影ボタンを追加
        let takeButton = UIButton(frame: CGRectMake(0.0 , 0.0, 100.0, 100.0))
        takeButton.backgroundColor = UIColor.greenColor();
        takeButton.layer.masksToBounds = true
        takeButton.layer.cornerRadius = 50.0
        takeButton.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-100)
        takeButton.addTarget(self, action: "takeStillPicture:", forControlEvents: .TouchUpInside)
        
        // 撮影ボタンをViewに追加.
        overlayView.addSubview(takeButton);
        
        // キャンセルボタンを追加
        let cancelButton = UIButton(frame: CGRectMake(0.0 , 0.0, 100.0, 40.0))
        cancelButton.backgroundColor = UIColor.redColor();
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 3.0
        cancelButton.layer.position = CGPoint(x: 60.0, y: 25.0)
        cancelButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)

        // キャンセルボタンをViewに追加.
        overlayView.addSubview(cancelButton);
        
        session.startRunning()
    }

    func takeStillPicture(sender: UIButton) {
        
        // ビデオ出力に接続.
        if let connection:AVCaptureConnection? = output.connectionWithMediaType(AVMediaTypeVideo){
            // ビデオ出力から画像を非同期で取得
            output.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (imageDataBuffer, error) -> Void in
                
                // 取得画像のDataBufferをJpegに変換
                let imageData:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
                
                // JpegからUIImageを作成.
                let image:UIImage = UIImage(data: imageData)!
                
                // アルバムに追加.
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                
                // 確認画面へ
                
            })
        }
    }
    
    func cancel(sender: UIButton) {
        print("cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
