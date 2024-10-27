//
//  VacationModel.swift
//  travelmap
//
//  Created by 齋藤温仁 on 2024/08/04.
//

import Foundation
import SwiftData

@Model
final class VacationModel {
    @Attribute(.unique) var id: String
    var vacationName: String
    var memo: String
    var timeRequired: Double
    var stayMin: Double
    var websiteURL: String
    var latitude: Double
    var longitude: Double
    var createdAt: Date
    
    
    init(id: String, vacationName: String, memo:String, timeRequired: Double, stayMin: Double, websiteURL: String, createdAt: Date, latitude: Double, longitude: Double) {
        self.id = id
        self.vacationName = vacationName
        self.memo = memo
        self.timeRequired = timeRequired
        self.stayMin = stayMin
        self.websiteURL = websiteURL
        self.createdAt = createdAt
        self.latitude = latitude
        self.longitude = longitude
    }
}
