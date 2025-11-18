//
//  SoundManager.swift
//  FinalChallenge
//
//  Created by Euginia Gabrielle on 17/11/25.
//

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?
    
    enum SoundOption: String {
        case buttonClick = "sfx_button"
        case buttonCloseClick = "sfx_buttonClose"
        case bubbleClick = "sfx_bubble"
        case reward = "sfx_reward"
        case moneyIn = "sfx_money"
        case goalFinish = "sfx_goal"
        case stoneProgress = "sfx_stone"
        case robotTalk = "sfx_robot"
    }
    
    func play(_ sound: SoundOption) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            print("Sound file not found: \(sound.rawValue)")
            return
        }
        
        do {
            // setup player
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}
