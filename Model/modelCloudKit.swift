//
//  modelCloudKit.swift
//  CloudAlunos
//
//  Created by Paulo Uchôa on 21/10/20.
//

import Foundation
import CloudKit

class modelCloudKit {
    
    let container : CKContainer
    let databasePrivate : CKDatabase
    
    static var currentModel = modelCloudKit()
    
    init() {
        container = CKContainer.default()
        databasePrivate = container.privateCloudDatabase
    }
    
    func fetchAlunos (_ completion: @escaping (Result<[Aluno], Error>) -> Void){
        
        
        let predicate = NSPredicate(value: true)
//        let predicate = NSPredicate(format: "Nome == %@", "Soneca")
        
        let query = CKQuery(recordType: "Aluno", predicate: predicate)

        databasePrivate.perform(query, inZoneWith: CKRecordZone.default().zoneID){results, errors in

            if let error = errors{
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }

            guard let result = results else { return }

            let alunos = result.compactMap {
                Aluno.init(record: $0)
            }

            DispatchQueue.main.async {
                completion(.success(alunos))
            }

            }
        }

}
