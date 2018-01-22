//
//  FirebaseConnectionTest.swift
//  myInstagramTests
//
//  Created by XIN LIU on 1/10/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import XCTest
import Firebase

@testable import myInstagram
class FirebaseConnectionTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDatabase(){
        //test getUserInfo function. the same we can test getpublic userinfo function
//        let myExpectation = XCTestExpectation(description: "My firebase works fine")
//        let testUser = ["UserName" : "testcase", "EmailId" : "testcaseemail@email.com"]
//        Auth.auth().createUser(withEmail:"testcaseemail@yahoo.com", password: "123456"){
//            (user,error) in
//            XCTAssertNil(error)
//            XCTAssertNotNil(user)
//
//        Database.database().reference().child("Users").child(user!.uid).updateChildValues(testUser)
//
//        //read this user from database
//            AccessFirebase.sharedAccess.getUserInfo(uid :user!.uid){ (userinfo, friendlist)  in
//
//                XCTAssertNotNil(userinfo)
//
//                if let userDict = userinfo as? [String : String]{
//                    XCTAssertNotNil(userDict["UserName"])
//                    XCTAssertEqual("testcase", userDict["UserName"])
//
//                }
//                myExpectation.fulfill()
//            }
//        }
//
//        let res = XCTWaiter().wait(for: [myExpectation], timeout: 10)
        
    }
    
}








