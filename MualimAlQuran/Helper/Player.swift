import SwiftUI
import AVFoundation


extension Notification.Name {
    static let appNavigationBack = Notification.Name("MualimAlQuran.navigationBack")
}

@MainActor
enum AppNavigationAudio {
    private(set) static var revision = UUID()

    static func stopForBack() {
        // Pending downloads may save their files, but may not start old audio.
        revision = UUID()
        NotificationCenter.default.post(name: .appNavigationBack, object: nil)
    }
}

class Player: NSObject, AVAudioPlayerDelegate, ObservableObject {
    
    var player = AVAudioPlayer()
    var type: String = ""
    var vm: RecitationItem?
    
    @Published var playing = false
    @MainActor var onNavigationBack: (@MainActor () -> Void)?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
            selector: #selector(stopForNavigationBack(_:)), name: .appNavigationBack, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @MainActor @objc private func stopForNavigationBack(_ notification: Notification) {
        onNavigationBack?()
        vm = nil
        player.delegate = nil
        stop()
    }
            
    func play(url: URL) {
        
        player = try! AVAudioPlayer(contentsOf: url)
        player.delegate = self
        
        audioSilent()
        player.play()
        
        DispatchQueue.main.async {
            guard self.player.isPlaying else { return }
            self.playing = true
        }
    }
    
    func stop() {
        
        player.stop()
        
        DispatchQueue.main.async {
            self.playing = false
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

        guard player === self.player else { return }
        playing = false
        
        if (type == "recitation") {
            
            vm?.playVerseCompleted()            
        }
        else if (type == "translation") {
            
            vm?.playTranslationCompleted()
        }
        else if (type == "word") {
            vm?.playWordCompleted()
        }
    }
    
    func pause() {
        
        player.pause()
    }
    
    func play() {
        audioSilent()
        player.play()
    }
}

func audioSilent() {
    
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback)
    }
    catch {
        
    }
}
