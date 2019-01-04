//
//  ViewController.swift
//  DAF_v1
//
//  Created by Sharan Narasimhan on 16/11/18.
//  Copyright © 2018 Sharan Narasimhan. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    
    @IBOutlet weak var startDAF: UIButton!
    
    @IBOutlet weak var startRecording: UIButton!
    
    var recordingSession : AVAudioSession!
    
    
    var audioRecorder : AVAudioRecorder!
    var audioRecorderSecondary: AVAudioRecorder!
    
    // making a second audio engine
    var audioPlayer : AVAudioPlayer!
    var audioPlayerSecondary: AVAudioPlayer!
    
    var fileNameString : String = "test.m4a"
    
    // second file directory
    var fileNameStringSecondary : String = "testSecondary.m4a"
    
    var timeInterval: Double = 0.1; // number of seconds
    var finishedPlaying: Bool = true
    var doDAF: Bool = false;
    

    let settings = [AVFormatIDKey: Int(kAudioFormatAppleLossless),
                    AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                    AVEncoderBitRateKey: 320000,
                    AVNumberOfChannelsKey: 1,
                    AVSampleRateKey: 12000.0] as [String : Any]
    
    let settingsSecondary = [AVFormatIDKey: Int(kAudioFormatAppleLossless),
                    AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                    AVEncoderBitRateKey: 320000,
                    AVNumberOfChannelsKey: 1,
                    AVSampleRateKey: 12000.0] as [String : Any]
    
    
    
    
    
    
    
    @IBAction func buttonPressedDAF(_ sender: UIButton) {
        
        if(self.doDAF == false){ // needs to start DAF
            self.doDAF = true
            
            
            //self.recordAndPlayPrimary()
            self.recordAndPlayPrimary()
            
            
            self.startDAF.setTitle("Stop DAF", for: .normal)
            
        }
        else if (self.doDAF == true) // already playing.. needs to stop
        {    self.doDAF = false
             self.startDAF.setTitle("Start DAF", for: .normal)
        }
        else {
            // do nothing
        }
      }
    
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        print("button pressed")
        let filename = getDirectory().appendingPathComponent("\(fileNameString)")

        if audioRecorder == nil{ // DAF needs to be started
            
            let settings = [AVFormatIDKey: Int(kAudioFormatAppleLossless),
                            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                            AVEncoderBitRateKey: 320000,
                            AVNumberOfChannelsKey: 1,
                            AVSampleRateKey: 12000.0] as [String : Any]
            
            do{
            
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                startRecording.setTitle("Stop ", for: .normal)
                
            } catch{
                print ("failed")
            }
            
        }
        else { // Audiorecorder is not nil.
            
            audioRecorder.stop()
            audioRecorder = nil
            
            startRecording.setTitle("Start", for: .normal)
            playRecording()
            
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("init loaded...")
        self.initializeRecorder()
        self.initializeRecorderSecondary()
        
    }
    
    func initializeRecorder(){
        
         let filename = getDirectory().appendingPathComponent("\(fileNameString)")
        do{
         audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
         audioRecorder.delegate = self
        }
        catch {
            print ("failed")
        }
    }
    
    func initializeRecorderSecondary(){
        
        let filename = getDirectory().appendingPathComponent("\(fileNameStringSecondary)")
        do{
            audioRecorderSecondary = try AVAudioRecorder(url: filename, settings: settingsSecondary)
            audioRecorderSecondary.delegate = self
        }
        catch {
            print ("failed")
        }
    }
    
    
    func playRecording(){
        
        let filename = getDirectory().appendingPathComponent("\(fileNameString)")
        
        do{
        audioPlayer = try AVAudioPlayer(contentsOf: filename, fileTypeHint: nil)
        }
        catch let error{
            print("\(error)")
        }
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    func playRecordingSecondary(){
        
        let filename = getDirectory().appendingPathComponent("\(fileNameStringSecondary)")
        
        do{
            audioPlayerSecondary = try AVAudioPlayer(contentsOf: filename, fileTypeHint: nil)
        }
        catch let error{
            print("\(error)")
        }
        audioPlayerSecondary.delegate = self
        audioPlayerSecondary.prepareToPlay()
        audioPlayerSecondary.play()
    }
    
    
    
    func getDirectory() -> URL{ // get the default directory to stroe audio files
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    
    func recordAndPlayPrimary(){ // TO DO: reduce the latency of the function
        
        if(audioRecorder.record(forDuration: timeInterval )) // returns true if the recording has started...
        {
            //print("started recording for \(timeInterval) seconds...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) { // waits for timeInterval seconds for the audio to record, then executes dispatchQueue.main
                
                self.audioRecorder.stop()
                
                self.playRecording()
                
                // while primary recording in playing... record from secondary engine
                if self.doDAF == true {
                    self.recordAndPlaySecondary()
                }
                
                
                //while self.audioPlayer.isPlaying == true { // audio is still playing, dont proceed
                    //print("audio player is playing...")
                //}
                
                //self.recordAndPlay()
            }
        }
        
    }
    
    func recordAndPlaySecondary(){ // TO DO: reduce the latency of the function
        
        if(audioRecorderSecondary.record(forDuration: timeInterval )) // returns true if the recording has started...
        {
            //print("started recording for \(timeInterval) seconds...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) { // waits for timeInterval seconds for the audio to record, then executes dispatchQueue.main
                
                self.audioRecorderSecondary.stop()
                
                self.playRecordingSecondary()
                
                if self.doDAF == true{
                    self.recordAndPlayPrimary()
                }
                
                
                //while self.audioPlayerSecondary.isPlaying == true { // audio is still playing, dont proceed
                    //print("audio player is playing...")
                //}
                
            }
        }
        
    }
    
    
    
    
    

}

