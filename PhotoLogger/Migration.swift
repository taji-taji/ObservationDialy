//
//  Migration.swift
//  PhotoLogger
//
//  Created by tajika on 2015/11/25.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import Foundation
import RealmSwift

class Migration {

    let config = Realm.Configuration(
        schemaVersion: 1,
    
        // Set the block which will be called automatically when opening a Realm with
        // a schema version lower than the one set above
        migrationBlock: { migration, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
    })

    // Tell Realm to use this new configuration object for the default Realm
    Realm.Configuration.defaultConfiguration = config
    
}

// Now that we've told Realm how to handle the schema change, opening the file
// will automatically perform the migration
let realm = try! Realm()