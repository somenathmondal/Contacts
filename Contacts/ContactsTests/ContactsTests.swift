//
//  ContactsTests.swift
//  ContactsTests
//
//  Created by Somenath on 17/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import XCTest
@testable import Contacts

class ContactsTests: XCTestCase {
    
    var sut: URLSession!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        sut = URLSession(configuration: .default)
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()
    }

    func testContactDetails() {
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let contactDetailVM = ContactDetailsViewModel()
        
        let contact = Contact(favorite: 1, first_name: "Some", last_name: "Name", id: 1234, profile_pic: nil, url: nil, email: "somename@gmail.com", phone_number: "33455677899", created_at: nil, updated_at: nil)
        
        contactDetailVM.contactDetails = contact
        
        XCTAssertEqual(contact.id, contactDetailVM.contactDetails?.id)
        XCTAssertEqual(contact.favorite, contactDetailVM.contactDetails?.favorite)
        XCTAssertEqual(contact.first_name, contactDetailVM.contactDetails?.first_name)
        XCTAssertEqual(contact.last_name, contactDetailVM.contactDetails?.last_name)
        XCTAssertEqual(contact.email, contactDetailVM.contactDetails?.email)
        XCTAssertEqual(contact.phone_number, contactDetailVM.contactDetails?.phone_number)
    }

    func testCallToContactsCompletes() {
      // given
      let url =
        URL(string: contactsURL)
      let promise = expectation(description: "Completion handler invoked")
      var statusCode: Int?
      var responseError: Error?

      // when
      let dataTask = sut.dataTask(with: url!) { data, response, error in
        statusCode = (response as? HTTPURLResponse)?.statusCode
        responseError = error
        promise.fulfill()
      }
      dataTask.resume()
      wait(for: [promise], timeout: 5)

      // then
      XCTAssertNil(responseError)
      XCTAssertEqual(statusCode, 200)
    }


}
