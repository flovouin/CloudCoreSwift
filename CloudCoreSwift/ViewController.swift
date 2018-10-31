//
//  ViewController.swift
//  CloudCoreSwift
//
//  Created by Flo Vouin on 31/10/2018.
//  Copyright © 2018 flovouin. All rights reserved.
//

import UIKit
import YapDatabase

class ViewController: UIViewController, YapDatabaseCloudCorePipelineDelegate {
    private let extensionName = "myExtension"
    private let collectionName = "myCollection"

    private var database: YapDatabase?
    private var connection: YapDatabaseConnection?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let baseDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let database = YapDatabase(path: baseDir.appendingPathComponent("mydb.sqlite").path) else { return }

        self.database = database
        self.connection = database.newConnection()

        let pipeline = YapDatabaseCloudCorePipeline(name: YapDatabaseCloudCoreDefaultPipelineName, delegate: self)
        let myExtension = MyExtension()
        myExtension.register(pipeline)
        database.register(myExtension, withName: self.extensionName)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.write(item: Item(id: "first_item"))
    }

    // MARK: - Read & write
    private func write(item: Item) {
        guard let connection = self.connection else { return }

        connection.readWrite { transaction in
            transaction.setObject(item, forKey: item.id, inCollection: self.collectionName)
        }
    }

    private func item(with itemID: String) -> Item? {
        guard let connection = self.connection else { return nil }

        var item: Item?
        connection.read { transaction in
            item = transaction.object(forKey: itemID, inCollection: self.collectionName) as? Item
        }
        return item
    }

    // MARK: - YapDatabaseCloudCorePipelineDelegate
    @objc
    func start(_ operation: YapDatabaseCloudCoreOperation!, for pipeline: YapDatabaseCloudCorePipeline!) {
        guard let itemID = operation.itemID, let item = self.item(with: itemID) else {
            self.complete(operation, success: false)
            return
        }

        print("Synchronizing \(item.id)")
        self.complete(operation, success: true)
    }

    private func complete(_ operation: YapDatabaseCloudCoreOperation, success: Bool) {
        self.connection?.readWrite { transaction in
            guard let cloudTransaction = transaction.ext(self.extensionName) as? MyExtensionTransaction else { return }

            if success {
                cloudTransaction.completeOperation(with: operation.uuid)
            } else {
                cloudTransaction.skipOperation(with: operation.uuid)
            }
        }
    }
}
