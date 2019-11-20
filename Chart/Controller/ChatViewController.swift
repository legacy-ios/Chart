//
//  ChartViewController.swift
//  Chart
//
//  Created by jungwooram on 2019-11-18.
//  Copyright © 2019 jungwooram. All rights reserved.
//

import UIKit
import Firebase
class ChatViewController: UIViewController {
    
    var messages:[Message] = []
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessage()
    }
    
    func loadMessage() {
        
        messages = []
        
        db.collection(K.FStore.collectionName).getDocuments { (quartSnapshot, error) in
            
            if let e = error{
                print(e.localizedDescription)
            }else{
                if let snapshotDocuments = quartSnapshot?.documents{
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        if let senderMessage = data[K.FStore.senderField] as? String, let bodyMessage = data[K.FStore.bodyField] as? String{
                            let message = Message(sender: senderMessage, body: bodyMessage)
                            self.messages.append(message)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextField.text, let messageSender = Auth.auth().currentUser?.email{
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody
            ]) { (error) in
                if let e = error{
                    print(e.localizedDescription)
                }else{
                    print("Success")
                    self.loadMessage()
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    

}






// MARK: - TableViewDataSource
extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label?.text = messages[indexPath.row].body
        
        return cell
    }
    
       
}
