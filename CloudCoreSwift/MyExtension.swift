//
//  MyExtension.swift
//  CloudCoreSwift
//
//  Created by Flo Vouin on 31/10/2018.
//  Copyright © 2018 flovouin. All rights reserved.
//
import Foundation

import YapDatabase.YapDatabaseExtensionPrivate
import YapDatabase.YapDatabaseCloudCore
import YapDatabase.YapDatabaseCloudCorePrivate

class Item: NSObject, NSCoding {
    let id: String

    init(id: String) {
        self.id = id

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: "id") as? String else { return nil }

        self.id = id

        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
    }
}

class MyExtension: YapDatabaseCloudCore {
    override init() {
        super.init(versionTag: "", options: nil)
    }

    override func newConnection(_ databaseConnection: YapDatabaseConnection) -> YapDatabaseExtensionConnection {
        return MyExtensionConnection(parentExtension: self, databaseConnection: databaseConnection)
    }
}

class MyExtensionConnection: YapDatabaseCloudCoreConnection {
    init(parentExtension: MyExtension, databaseConnection: YapDatabaseConnection) {
        super.init(parent: parentExtension, databaseConnection: databaseConnection)
    }

    override func newReadTransaction(_ databaseTransaction: YapDatabaseReadTransaction) -> Any {
        return MyExtensionTransaction(parentConnection: self, databaseTransaction: databaseTransaction)
    }

    override func newReadWriteTransaction(_ databaseTransaction: YapDatabaseReadWriteTransaction) -> Any {
        let transaction = MyExtensionTransaction(parentConnection: self, databaseTransaction: databaseTransaction)
        self.prepareForReadWriteTransaction()
        return transaction
    }
}

class MyExtensionTransaction: YapDatabaseCloudCoreTransaction {
    override init(parentConnection: YapDatabaseCloudCoreConnection!, databaseTransaction: YapDatabaseReadTransaction!) {
        super.init(parentConnection: parentConnection, databaseTransaction: databaseTransaction)
    }

    override func didInsert(_ object: Any, for collectionKey: YapCollectionKey, withMetadata metadata: Any?,
                            rowid: Int64) {
        guard let item = object as? Item else { return }

        let operation = YapDatabaseCloudCoreOperation()
        operation.itemID = item.id
        self.add(operation)
    }

    override func didUpdate(_ object: Any, for collectionKey: YapCollectionKey, withMetadata metadata: Any?,
                            rowid: Int64) {
    }

    override func didReplace(_ object: Any, for collectionKey: YapCollectionKey, withRowid rowid: Int64) {
    }

    override func didReplaceMetadata(_ metadata: Any, for collectionKey: YapCollectionKey, withRowid rowid: Int64) {
    }

    override func didTouchRow(for collectionKey: YapCollectionKey, withRowid rowid: Int64) {
    }

    override func didTouchObject(for collectionKey: YapCollectionKey, withRowid rowid: Int64) {
    }

    override func didTouchMetadata(for collectionKey: YapCollectionKey, withRowid rowid: Int64) {
    }

    override func didRemoveObject(for collectionKey: YapCollectionKey, withRowid rowid: Int64) {
    }

    override func didRemoveObjects(forKeys keys: [Any], inCollection collection: String, withRowids rowids: [Any]) {
    }

    override func didRemoveAllObjectsInAllCollections() {
    }
}

extension YapDatabaseCloudCoreOperation {
    var itemID: String? {
        get {
            return self.persistentUserInfo?["itemID"] as? String
        }

        set(value) {
            self.setPersistentUserInfoObject(value, forKey: "itemID")
        }
    }
}
