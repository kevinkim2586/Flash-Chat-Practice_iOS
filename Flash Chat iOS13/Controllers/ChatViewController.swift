
import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        title = K.appName
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        
        loadMessages()

        
    }
    
    func loadMessages(){
 
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot, err) in
            
            self.messages = []
            
            if let err = err{
                print("There was an issue retrieving data from Firestore \(err)")
            }
            else{
                
                if let snapshotDocuments = querySnapshot?.documents{
                    
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String{
                            
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                             
                            DispatchQueue.main.async {      // We are in a closure, meaning the method 수행 is happening in the
                                                            // background. But when we need to update the tableView, we have to
                                                            // do this in the main thread
                                
                          
                                self.tableView.reloadData()
                            }
                        }
                    }
                    

                }
            }
        }
    }
    
    
    
    
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        // Optional Binding -> Checking if both are not nil first
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
            
            // Then, we send the data to the DB
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970
                ]) { (error) in
                if let e = error{
                    print("There was an issue saving data to firestore, \(e)")
                }
                else{
                    print("Successfully saved data")
                }
            }
        }
        
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            // Continue without errors
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

    }
    
}

//MARK: - UITableViewDataSource

//UITableViewDataSource is a protocol responsibile in populating the data

extension ChatViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    // We have to create a cell and return it
    // 위의 messages.count 만큼 실행이됨
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell  //ReusableCell
        
        // Give the cell some data
        cell.label.text = messages[indexPath.row].body
        return cell
    }
  
}

