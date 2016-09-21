//
//  NotifySpeaker.swift
//  12306ForMac
//
//  Created by fancymax on 16/9/17.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

class NotifySpeaker {
    private static let sharedManager = NotifySpeaker()
    class var sharedInstance: NotifySpeaker {
        return sharedManager
    }
    
    private let speachSynth: NSSpeechSynthesizer
    
    private init () {
        speachSynth = NSSpeechSynthesizer()
        let isSuccess = speachSynth.setVoice("com.apple.speech.synthesis.voice.mei-jia")
        if !isSuccess {
            speachSynth.setVoice("com.apple.speech.synthesis.voice.ting-ting")
        }
    }
    
    func notify() {
        if GeneralPreferenceManager.sharedInstance.isNotifyTicket {
            speachSynth.startSpeakingString(GeneralPreferenceManager.sharedInstance.notifyStr)
        }
    }
    
    func stopNotify(){
        speachSynth.stopSpeaking()
    }
    
    func notifyLogin() {
        if GeneralPreferenceManager.sharedInstance.isNotifyLogin {
            speachSynth.startSpeakingString(GeneralPreferenceManager.sharedInstance.notifyLoginStr)
        }
    }
    
}
