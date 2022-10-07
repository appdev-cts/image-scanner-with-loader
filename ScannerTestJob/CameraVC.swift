//
//  CameraVC.swift
//  ScannerTestJob
//
//  Created by apple on 07/10/22.
//

import UIKit
import AVFoundation
import Lottie

class CameraVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet weak var scanningBottomLabel: UILabel!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    private var lottieAnimation: AnimationView?
    let ANIMATION_SIZE: CGFloat = 220
    let LABEL_SIZE: CGFloat = 220

    var progressLabel: UILabel!
    var scanningLabel: UILabel!
    
    var timer = Timer()
    var counter: Int = 0
    var delayOnComplete = false
    
    let DEFAULT_BOTTOM_TEXT = "Please wait while scanning is completed"
    let COMPLETED_BOTTOM_TEXT = "Scanning completed successfully"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        setupCamera()
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _timer in
            self.setupAnimationView()
            self.setupProgressLabel()
            self.setupTimer()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
        if(self.timer.isValid) {
            self.timer.invalidate()
        }
    }
    
    //MARK:- Back Button
    @IBAction func onBackPress(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Animation Setup (loader view)
    func setupAnimationView() {
        self.lottieAnimation = AnimationView(name: "loader")
        self.lottieAnimation?.frame = CGRect(x: 0,
                                                 y: 0,
                                                 width: ANIMATION_SIZE,
                                                 height: ANIMATION_SIZE)
        self.lottieAnimation?.contentMode = .scaleToFill
        self.lottieAnimation?.center = self.view.center
        self.lottieAnimation?.loopMode = .loop
        self.view.addSubview(self.lottieAnimation!)
        self.lottieAnimation?.play(completion: nil)
    }
    
    //MARK:- Progress Label Setup
    func setupProgressLabel() {
        self.progressLabel = UILabel(frame: CGRect(x: 0, y: 0, width: LABEL_SIZE, height: LABEL_SIZE))
        self.progressLabel?.center = self.view.center
        self.progressLabel.textColor = .white
        self.progressLabel.textAlignment = .center
        self.progressLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.view.addSubview(self.progressLabel!)
        
        self.scanningLabel = UILabel(frame: CGRect(x: (self.lottieAnimation?.frame.origin.x)!, y: (self.lottieAnimation?.frame.origin.y)! + ANIMATION_SIZE, width: LABEL_SIZE, height: 50))
        self.scanningLabel.textColor = .white
        self.scanningLabel.textAlignment = .center
        self.view.addSubview(self.scanningLabel!)
    }
    
    //MARK:- Timer Setup
    func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true, block: { [self] _timer in
            self.counter = self.counter >= 100 ? 0 : self.counter + 2
            self.progressLabel.text = "\(self.counter)%"
            if(!self.delayOnComplete) {
                self.scanningLabel.text = self.counter < 100 ? "Scanning..." : "Scanning completed"
                self.scanningBottomLabel.text = self.counter < 100 ? DEFAULT_BOTTOM_TEXT : COMPLETED_BOTTOM_TEXT
            }
            if(self.counter == 100) {
                self.delayOnComplete = true
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { __timer in
                    self.delayOnComplete = false
                }
            }
        })
    }
    
    //MARK:- Camera Setup
    func setupCamera() {
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
    }
    
    //MARK:- Camera Preview Setup
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        viewCamera.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.viewCamera.bounds
            }
        }
    }
    
}

