//
//  BarCodeScanner.swift
//  re<ycle
//
//  Created by Robin Leman on 01/02/2020.
//  Copyright © 2020 Lorne & Leman Corp. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import Foundation


class BarCodeScanner: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
        
        @IBOutlet weak var imageView :UIImageView!
        @IBOutlet var barCodeRawValueLabel :UILabel!
        
        let session = AVCaptureSession()
        lazy var vision = Vision.vision()
        var barcodeDetector :VisionBarcodeDetector?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.startLiveVideo()
            self.barcodeDetector = vision.barcodeDetector()
        
        
    }
        
       func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
            if let barcodeDetector = self.barcodeDetector {
                
                let visionImage = VisionImage(buffer: sampleBuffer)
                
                barcodeDetector.detect(in: visionImage) { (barcodes, error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    for barcode in barcodes! {
                         print(barcode.rawValue!)
                         let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

                        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "Product Result") as! ProductResult

                        self.present(resultViewController, animated:true, completion:nil)
                    }
                }
            }
        }
        
    
        
        private func startLiveVideo() {
            
            session.sessionPreset = AVCaptureSession.Preset.high
            let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            
            let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
            let deviceOutput = AVCaptureVideoDataOutput()
            deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
            session.addInput(deviceInput)
            session.addOutput(deviceOutput)

            let imageLayer = AVCaptureVideoPreviewLayer(session: session)
            imageLayer.frame = CGRect(x: 0, y: 0, width: self.imageView.frame.size.width + 100, height: self.imageView.frame.size.height)
            imageLayer.videoGravity = .resizeAspectFill
            imageView.layer.addSublayer(imageLayer)
            
            session.startRunning()
        }
        
    
}



