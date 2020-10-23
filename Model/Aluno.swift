//
//  Aluno.swift
//  CloudAlunos
//
//  Created by Paulo Uchôa on 21/10/20.
//

import Foundation
import CloudKit

class Aluno {
    
    static let recordType = "Aluno"
    let id : CKRecord.ID
    var Nome: String
    var Numero: String
    
    init?(record: CKRecord) {
        guard let  nome = record["Nome"] as? String, let numero = record["Numero"] as? String else {return nil}
        id = record.recordID
        self.Nome = nome
        self.Numero = numero
    }
    
}

