//
//  ViewController.swift
//  CloudAlunos
//
//  Created by Paulo Uchôa on 21/10/20.
//

import UIKit
import CloudKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var container = modelCloudKit().container
    var fetch = modelCloudKit()
    
    var arrayDeAlunos : [Aluno] = [] {
        didSet{
            DispatchQueue.main.async {
                for alunos in self.arrayDeAlunos{
                    print("Aluno: \(alunos.Nome)  Número: \(alunos.Numero)")
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    let recordIDs = [CKRecord.ID]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        getAlunos()
    }

    
    func getAlunos() {
        sleep(3)
        modelCloudKit.currentModel.fetchAlunos{response in
            switch response{
            case .success(let data):
                self.arrayDeAlunos = data
            case .failure(let error):
                print(error)
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getAlunosNoSleep() {
        modelCloudKit.currentModel.fetchAlunos{response in
            switch response{
            case .success(let data):
                self.arrayDeAlunos = data
            case .failure(let error):
                print(error)
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
//

    @IBAction func addTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Aluno", message: "Qual o nome do aluno?", preferredStyle: .alert)
        alert.addTextField()
        
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let textfield = alert.textFields![0]
            
            let newAluno = CKRecord(recordType: "Aluno")
            newAluno["Nome"] = textfield.text
            newAluno["Numero"] = "0"
                        
            self.container.privateCloudDatabase.save(newAluno) { (savedRecord, error) in
                        
                if error == nil {
                    print("Record Saved")
                } else {
                    print("Record Not Saved")
                            
                }
            }
            self.getAlunos()
        }
        
        alert.addAction(submitButton)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func searchTapped(_ sender: Any) {
        
        getAlunosNoSleep()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayDeAlunos.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let aluno = self.arrayDeAlunos[indexPath.row]
    
        cell.textLabel?.text = aluno.Nome
        cell.detailTextLabel?.text = aluno.Numero

        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let aluno = self.arrayDeAlunos[indexPath.row]
        
        let alert = UIAlertController(title: "Editar Aluno", message: "Editar nome:", preferredStyle: .alert)
        alert.addTextField()

        let textfield = alert.textFields![0]
        textfield.text = aluno.Nome

        let saveButton = UIAlertAction(title: "Save", style: .default) { (action) in
            
            self.container.privateCloudDatabase.fetch(withRecordID: aluno.id) { (record, error) in
                
                if error == nil {
                     
                    record?.setValue(textfield.text, forKey: "Nome")
                    
                        
                        self.container.privateCloudDatabase.save(record!) { (editrecord, error) in
                            
                            if error == nil {
                                print("Record Saved")
                                
                            }else{
                               print("Record Not Saved")
                            }
                            
                        }
                    
                } else {
                    
                    print("Erro in fetch")
                }
            
            }
            self.getAlunos()
        }
        alert.addAction(saveButton)
        self.present(alert, animated: true, completion: nil)
        
    }


    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in

            let personToRemove = self.arrayDeAlunos[indexPath.row]
            
            self.container.privateCloudDatabase.delete(withRecordID: personToRemove.id) { (record, error) in
                
                if error == nil {
                    print("Record Delete")
                } else {
                    print("Record Not Delete")
                    
                }
            }
            self.getAlunos()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
