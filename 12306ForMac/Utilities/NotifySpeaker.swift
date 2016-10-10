//
//  NotifySpeaker.swift
//  12306ForMac
//
//  Created by fancymax on 16/9/17.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Foundation

class NotifySpeaker {
    fileprivate static let sharedManager = NotifySpeaker()
    class var sharedInstance: NotifySpeaker {
        return sharedManager
    }
    
    fileprivate let speachSynth: NSSpeechSynthesizer
    
    fileprivate init () {
        speachSynth = NSSpeechSynthesizer()
        let isSuccess = speachSynth.setVoice("com.apple.speech.synthesis.voice.mei-jia")
        if !isSuccess {
            speachSynth.setVoice("com.apple.speech.synthesis.voice.ting-ting")
        }
    }
    
    func notify() {
        if GeneralPreferenceManager.sharedInstance.isNotifyTicket {
            speachSynth.startSpeaking(GeneralPreferenceManager.sharedInstance.notifyStr)
        }
    }
    
    func stopNotify(){
        speachSynth.stopSpeaking()
    }
    
    func notifyLogin() {
        if GeneralPreferenceManager.sharedInstance.isNotifyLogin {
            speachSynth.startSpeaking(GeneralPreferenceManager.sharedInstance.notifyLoginStr)
        }
    }
    
}
