//
//  SwiftDataService.swift
//  travelmap
//
//  Created by 齋藤温仁 on 2024/08/04.
//

import Foundation
import SwiftData

class SwiftDataService {
    static let shared = SwiftDataService()
    var container: ModelContainer?
    var context: ModelContext?
    
    init(){
        do{
            container = try ModelContainer(for: VacationModel.self)
            if let container{
                context = ModelContext(container)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func saveVacation(vacationName: String,memo: String, timeRequired: Double, stayMin: Double, websiteURL: String, createdAt: Date, latitude: Double, longitude: Double){
        if let context {
            let savedVacation = VacationModel(id: UUID().uuidString,
                                              vacationName: vacationName,
                                              memo: memo,
                                              timeRequired: timeRequired,
                                              stayMin: stayMin,
                                              websiteURL: websiteURL,
                                              createdAt: createdAt,
                                              latitude: latitude,
                                              longitude: longitude)
            context.insert(savedVacation)
        }
    }
    
    func fetchVacation(onCompletion: @escaping([VacationModel]?, Error?) -> Void) {
        let descriptor = FetchDescriptor<VacationModel>(sortBy: [SortDescriptor<VacationModel>(\.createdAt)])
        
        if let context{
            do{
                let data = try context.fetch(descriptor)
                onCompletion(data, nil)
            }catch{
                onCompletion(nil, error)
            }
        }
    }
    
    func deleteVacation(vacationModel: VacationModel){
        if let context{
            context.delete(vacationModel)
        }
    }
    
    func updateVacation(vacationModel: VacationModel, memo: String, timeRequired: Double, stayMin: Double, websiteURL: String) {
            vacationModel.memo = memo
            vacationModel.timeRequired = timeRequired
            vacationModel.stayMin = stayMin
            vacationModel.websiteURL = websiteURL
        }
}
