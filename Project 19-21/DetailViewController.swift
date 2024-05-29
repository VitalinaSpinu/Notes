//
//  DetailViewController.swift
//  Project 19-21
//
//  Created by Dmitrii Vrabie on 29.04.2024.
//

import UIKit

protocol AddNotesDelegate {
    func addNote(note: Note)
}

class DetailViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    var delegate: AddNotesDelegate?
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action:  #selector(handlerSave))
        let shareTapped = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [saveButton, space, shareTapped]
        
        if let textview = text {
            textView.text = textview
        }
        textView.becomeFirstResponder()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func handlerSave() {
        guard let fullNote = textView.text, textView.hasText else {
            return
        }
        let note = Note(fullNote: fullNote)
        delegate?.addNote(note: note)
        navigationController?.popViewController(animated: true)
        
    }
    @objc func shareTapped() {
        let vc = UIActivityViewController(activityItems: [textView.text as Any], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
}
