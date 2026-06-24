//
//  LRUCacheTests.swift
//  MaximusPrecisionTests
//

import XCTest
@testable import MaximusPrecision

final class LRUCacheTests: XCTestCase {

    func test_storesAndReturnsValues() {
        let cache = LRUCache<String, Int>(capacity: 4)
        cache.set(1, forKey: "a")
        cache.set(2, forKey: "b")
        XCTAssertEqual(cache.value(forKey: "a"), 1)
        XCTAssertEqual(cache.value(forKey: "b"), 2)
        XCTAssertNil(cache.value(forKey: "missing"))
    }

    func test_evictsLeastRecentlyUsed() {
        let cache = LRUCache<String, Int>(capacity: 2)
        cache.set(1, forKey: "a")
        cache.set(2, forKey: "b")
        // Touch "a" so "b" becomes least-recently used.
        _ = cache.value(forKey: "a")
        cache.set(3, forKey: "c")

        XCTAssertEqual(cache.value(forKey: "a"), 1)
        XCTAssertNil(cache.value(forKey: "b"), "b should have been evicted")
        XCTAssertEqual(cache.value(forKey: "c"), 3)
        XCTAssertEqual(cache.count, 2)
    }

    func test_updatingExistingKeyDoesNotGrow() {
        let cache = LRUCache<String, Int>(capacity: 2)
        cache.set(1, forKey: "a")
        cache.set(2, forKey: "a")
        XCTAssertEqual(cache.value(forKey: "a"), 2)
        XCTAssertEqual(cache.count, 1)
    }

    func test_capacityIsAtLeastOne() {
        let cache = LRUCache<String, Int>(capacity: 0)
        XCTAssertEqual(cache.capacity, 1)
        cache.set(1, forKey: "a")
        cache.set(2, forKey: "b")
        XCTAssertEqual(cache.count, 1)
        XCTAssertNil(cache.value(forKey: "a"))
        XCTAssertEqual(cache.value(forKey: "b"), 2)
    }

    func test_subscriptAndRemoveAll() {
        let cache = LRUCache<String, Int>(capacity: 4)
        cache["x"] = 10
        XCTAssertEqual(cache["x"], 10)
        cache.removeAll()
        XCTAssertEqual(cache.count, 0)
        XCTAssertNil(cache["x"])
    }
}
