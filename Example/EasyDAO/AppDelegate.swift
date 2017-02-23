//
//  AppDelegate.swift
//  EasyDAO
//
//  Created by ton252 on 02/14/2017.
//  Copyright (c) 2017 ton252. All rights reserved.
//

import UIKit
import EasyDAO

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let database = try! JSONDataBase.shared(name: "new")
        let obj1 = JSONObject(type: "DOG", primaryId: "Bunny", json: ["master":"Anton"])
        let obj2 = JSONObject(type: "DOG", primaryId: "Bunny", json: ["master":"Anton"])
        let obj3 = JSONObject(type: "KAT", primaryId: "Bunny2", json: ["master":"Anton3"])
        
        database.persist([obj1,obj2,obj3])
        let new = database.read(id: "Bunny", type: "DOG")
        print(new)
        let pr = NSPredicate(format: "master CONTAINS[c] %@","3")
        let new2 = database.read(predicate: pr, type: "KAT")
        print(new2)
        //database.erase(id: "Bunny", type: "DOG")
        database.save()
        //print(database.objects)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

