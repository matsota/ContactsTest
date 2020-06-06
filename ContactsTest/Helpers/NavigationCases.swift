//
//  ConstantStrings.swift
//  ContactsTest
//
//  Created by Andrew Matsota on 04.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation

class NavigationCases {
    
    enum Transition: String, CaseIterable {
        // - VCs
        case ContactsVC
        case DetailContactVC
        
        // - cells
        case ContactsTVCell
        
        // - segue
        case contact_DetailContact
    }
    
    enum Entities: String, CaseIterable {
        
        case ContactsData
        
    }
    
}
