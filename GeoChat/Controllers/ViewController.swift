//
//  ChatViewController.swift
//  GeoChat
//
//  Created by Nick Sagan on 01.11.2021.
//

import UIKit
import MessengerKit
import Firebase

class ViewController: MSGMessengerViewController, MSGDelegate {
    
    let db = Firestore.firestore()
    var id = 10
    var user: User?
    
    // Users in the chat
    
    let steve = User(displayName: "Steve", avatar: #imageLiteral(resourceName: "MeAvatar"), avatarUrl: nil, isSender: true)
    
    let tim = User(displayName: "Tim", avatar: #imageLiteral(resourceName: "YouAvatar"), avatarUrl: nil, isSender: false)
    
    // Messages
    
    lazy var messages: [[MSGMessage]] = {
        return [
            [
                MSGMessage(id: 1, body: .emoji("🐙💦🔫"), user: tim, sentAt: Date()),
                MSGMessage(id: 4, body: .text("Beautiful GeoChat app"), user: tim, sentAt: Date()),
            ],
            [
                MSGMessage(id: 2, body: .text("Yeah sure, gimme 5"), user: user as! MSGUser, sentAt: Date()),
                MSGMessage(id: 3, body: .text("Okay ready when you are"), user: user as! MSGUser, sentAt: Date())
            ]
        ]
    }()
    
    // Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        user = User(displayName: (Auth.auth().currentUser?.email)! , isSender: true)
    }
    
    override func inputViewPrimaryActionTriggered(inputView: MSGInputView) {
        
        if inputView.message != "" {
            if let user = Auth.auth().currentUser?.email {
                
                id += 1
                let body: MSGMessageBody = .text(inputView.message)
                let message = MSGMessage(id: id, body: body, user: self.user as! MSGUser, sentAt: Date())
                insert(message)
                
                db.collection(K.FBase.collectionName).addDocument(data: [
                    K.FBase.userField : user,
                    K.FBase.messageID : id,
                    K.FBase.bodyField : inputView.message,
                    K.FBase.dateField : NSDate()
                ]) { (error) in
                    if let e = error{
                        print(e)
                    } else {
                        print("Successfully saved data")
                    }
                }
            }
        }
    }
    
    override func insert(_ message: MSGMessage) {
            
        collectionView.performBatchUpdates({
            if let lastSection = self.messages.last, let lastMessage = lastSection.last, lastMessage.user.displayName == message.user.displayName {
                self.messages[self.messages.count - 1].append(message)
                
                let sectionIndex = self.messages.count - 1
                let itemIndex = self.messages[sectionIndex].count - 1
                self.collectionView.insertItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])
                
            } else {
                self.messages.append([message])
                let sectionIndex = self.messages.count - 1
                self.collectionView.insertSections([sectionIndex])
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: true)
            self.collectionView.layoutTypingLabelIfNeeded()
        })
        
    }

    override func insert(_ messages: [MSGMessage], callback: (() -> Void)? = nil) {
        
        collectionView.performBatchUpdates({
            for message in messages {
                if let lastSection = self.messages.last, let lastMessage = lastSection.last, lastMessage.user.displayName == message.user.displayName {
                    self.messages[self.messages.count - 1].append(message)
                    
                    let sectionIndex = self.messages.count - 1
                    let itemIndex = self.messages[sectionIndex].count - 1
                    self.collectionView.insertItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])
                    
                } else {
                    self.messages.append([message])
                    let sectionIndex = self.messages.count - 1
                    self.collectionView.insertSections([sectionIndex])
                }
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: false)
            self.collectionView.layoutTypingLabelIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                callback?()
            }
        })
        
    }


}

// MARK: - MSGDataSource

extension ViewController: MSGDataSource {
    
    func numberOfSections() -> Int {
        return messages.count
    }
    
    func numberOfMessages(in section: Int) -> Int {
        return messages[section].count
    }
    
    func message(for indexPath: IndexPath) -> MSGMessage {
        return messages[indexPath.section][indexPath.item]
    }
    
    func footerTitle(for section: Int) -> String? {
        return "Just now"
    }
    
    func headerTitle(for section: Int) -> String? {
        return messages[section].first?.user.displayName
    }

}


//import UIKit
//import Firebase

//class ChatViewController: UIViewController {
//
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var messageTextfield: UITextField!
//
//    let db = Firestore.firestore()
//
//    var messages : [Message] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.dataSource = self
//        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
//        title = K.appName
//        navigationItem.hidesBackButton = true
//        loadMessages()
//    }
//
//    func loadMessages () {
//        db.collection(K.FStore.collectionName).order(by: "date").addSnapshotListener { (querySnapshot, error) in
//            self.messages = []
//            if let e = error {
//                print("Problems with getting data from Firebase: \(e)")
//            } else if let snapshotDocuments = querySnapshot?.documents {
//                for doc in snapshotDocuments {
//                    let data = doc.data()
//                    if let messageBody = data[K.FStore.bodyField] as? String, let messageSender = data[K.FStore.senderField] as? String {
//
//                        // From firestamp to Date and to NSDate
//                        let timestamp: Timestamp = data[K.FStore.dateField] as! Timestamp
//                        let RequestedDate = timestamp.dateValue()
//
//                        let newMessage = Message(sender: messageSender, body: messageBody, date: RequestedDate as NSDate)
//                        self.messages.append(newMessage)
//
//                        DispatchQueue.main.async {
//                            self.tableView.reloadData()
//                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
//                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    @IBAction func sendPressed(_ sender: UIButton) {
//
//        if messageTextfield.text != ""{
//        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
//            db.collection(K.FStore.collectionName).addDocument(data: [
//                K.FStore.senderField : messageSender,
//                K.FStore.bodyField : messageBody,
//                K.FStore.dateField : NSDate()
//            ]) { (error) in
//                if let e = error{
//                    print(e)
//                } else {
//                    print("Successfully saved data")
//                }
//            }
//        }
//        messageTextfield.text = ""
//        }
//    }
//    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
//        let firebaseAuth = Auth.auth()
//        do {
//            try firebaseAuth.signOut()
//            navigationController?.popToRootViewController(animated: true)
//        } catch let signOutError as NSError {
//            print("Error signing out: %@", signOutError)
//        }
//
//    }
//
//
//}
//
////MARK: - TableViewDataSource
//
//extension ChatViewController: UITableViewDataSource{
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let message = messages[indexPath.row]
//        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
//        // Message text
//        cell.messageLabel.text = messages[indexPath.row].body
//
//        // Message date. From NSDate to HH:mm
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH:mm"
//        let date = messages[indexPath.row].date // your NSDate object
//        let dateString = dateFormatter.string(from: date as Date)
//
//        if message.sender == Auth.auth().currentUser?.email{
//            cell.avatar.isHidden = false
//            cell.timeLabel.isHidden = false
//            cell.youAvatar.isHidden = true
//            cell.youTimeLabel.isHidden = true
//            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lighBlue)
//            cell.timeLabel.text = dateString
//        } else {
//            cell.avatar.isHidden = true
//            cell.timeLabel.isHidden = true
//            cell.youAvatar.isHidden = false
//            cell.youTimeLabel.isHidden = false
//            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
//            cell.youTimeLabel.text = dateString
//        }
//
//        return cell
//    }
//}

