import Firebase
import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        //Optional Chaining on two optionals
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
              
                if let e = error{
                    print(e.localizedDescription)
                }
                else{
                    //Navigate to the Chat View Controller
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                    
                }
                
            }
        }
        
        
    }
    
}
