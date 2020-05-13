//
//  AudioCommentCell.swift
//  AudioComments
//
//  Created by David Wright on 5/11/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioCommentCellDelegate: class {
    func didTogglePlayback()
    func didUpdateCurrentTime(time: TimeInterval)
    func didRewind15Seconds()
    func didSkipForward15Seconds()
    func didDeleteAudioComment()
}

class AudioCommentCell: UITableViewCell {

    var audioComment: AudioComment? {
        didSet {
            updateAudioInfoViews()
        }
    }
    
    var audioController: AudioPlayerController? {
        didSet {
            updateAudioPlayerViews()
        }
    }
    
    var delegate: AudioCommentCellDelegate?

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    
    // MARK: - View Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        timeSlider.value = 0
        timestampLabel.setMonospacedDigitSystemFont()
        durationLabel.setMonospacedDigitSystemFont()
        timeElapsedLabel.setMonospacedDigitSystemFont()
        timeRemainingLabel.setMonospacedDigitSystemFont()
    }
    
    @IBAction func togglePlayback(_ sender: UIButton) {
        delegate?.didTogglePlayback()
        updateAudioPlayerViews()
    }
    
    @IBAction func updateCurrentTime(_ sender: UISlider) {
        guard let audioComment = audioComment else { return }
        let newCurrentTime = TimeInterval(timeSlider.value) * audioComment.duration
        delegate?.didUpdateCurrentTime(time: newCurrentTime)
        updateAudioPlayerViews()
    }
    
    @IBAction func rewind15Seconds(_ sender: UIButton) {
        delegate?.didRewind15Seconds()
        updateAudioPlayerViews()
    }
    
    @IBAction func forward15Seconds(_ sender: UIButton) {
        delegate?.didSkipForward15Seconds()
        updateAudioPlayerViews()
    }
    
    @IBAction func deleteAudioComment(_ sender: UIButton) {
        delegate?.didDeleteAudioComment()
        updateAudioPlayerViews()
    }
    
    private func updateAudioInfoViews() {
        guard let audioComment = audioComment else { return }
        
        titleLabel.text = audioComment.title
        timestampLabel.text = Formatter.string(from: audioComment.timeStamp)
        durationLabel.text = Formatter.string(from: audioComment.duration)
    }
    
    private func updateAudioPlayerViews() {
        guard let audioController = audioController else { return }
        
        playButton.isSelected = audioController.isPlaying
        
        timeElapsedLabel.text = Formatter.string(from: audioController.elapsedTime)
        
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(audioController.duration)
        timeSlider.value = Float(audioController.elapsedTime)
        
        timeRemainingLabel.text = "-" + Formatter.string(from: audioController.timeRemaining)
    }
    
    func animate() {
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.contentView.layoutIfNeeded()
        })
    }

}


extension UILabel {
    func setMonospacedDigitSystemFont() {
        font = UIFont.monospacedDigitSystemFont(ofSize: font.pointSize, weight: .regular)
    }
}