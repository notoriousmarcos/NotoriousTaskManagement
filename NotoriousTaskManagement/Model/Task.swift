//
//  Task.swift
//  NotoriousTaskManagement
//
//  Created by Marcos Vinicius Brito on 07/08/23.
//

import Foundation

struct Task: Identifiable{
  var id = UUID() .uuidString
  var taskTitle: String
  var taskDescription: String
  var taskDate: Date
}
