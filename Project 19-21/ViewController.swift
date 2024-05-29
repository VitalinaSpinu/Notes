//
//  ViewController.swift
//  Project 19-21
//
//  Created by Dmitrii Vrabie on 25.04.2024.
//

import UIKit

class Note: NSObject, Codable {
    var fullNote: String
    
    init(fullNote: String) {
        self.fullNote = fullNote
    }
}

class ViewController: UITableViewController {
    
    var index: Int!
    var selectComposeButton: Bool!
    var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        
        let composeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(buttonAddNotes))
        navigationItem.rightBarButtonItems = [composeButton]
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButton))
        navigationItem.leftBarButtonItems = [deleteButton]
        
        let defaults = UserDefaults.standard
        
        if let savedNotes = defaults.object(forKey: "notes") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedNotes)
            } catch {
                print("Failed to load notes")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let fullNote = notes[indexPath.row].fullNote
        cell.textLabel?.text = fullNote
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startDetailViewController(note: notes[indexPath.row].fullNote)
        index = indexPath.row
    }

    @objc func buttonAddNotes() {
        selectComposeButton = true
        startDetailViewController(note: nil)
    }
    
    func startDetailViewController(note: String?) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.delegate = self
            vc.text = note
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ViewController: AddNotesDelegate {
    func addNote(note: Note) {
        if selectComposeButton == true   {
            notes.append(note)
            selectComposeButton = false
        } else {
            let oldNote = notes[index]
            if oldNote.fullNote == note.fullNote {
            } else {
                notes.remove(at: index)
                notes.insert(note, at: index)
            }
        }
        tableView.reloadData()
        save()
    }
    
    @objc func deleteButton() {
        notes.removeAll()
        tableView.reloadData()
    }
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "notes")
        } else {
            print("Failed to save notes.")
        }
    }
}
