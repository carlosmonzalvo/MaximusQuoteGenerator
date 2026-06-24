//
//  LRUCache.swift
//  MaximusPrecision
//
//  Small generic least-recently-used cache backed by a hash map + a doubly
//  linked list, so reads/writes are O(1) and the least-recently-used entry is
//  evicted once `capacity` is exceeded. Thread-safe via an internal lock.
//

import Foundation

final class LRUCache<Key: Hashable, Value> {

    private final class Node {
        let key: Key
        var value: Value
        var prev: Node?
        var next: Node?
        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }

    let capacity: Int
    private var map: [Key: Node] = [:]
    private var head: Node?   // most-recently used
    private var tail: Node?   // least-recently used
    private let lock = NSLock()

    init(capacity: Int) {
        self.capacity = max(1, capacity)
    }

    var count: Int {
        lock.lock(); defer { lock.unlock() }
        return map.count
    }

    /// Returns the value and marks the key as most-recently used.
    func value(forKey key: Key) -> Value? {
        lock.lock(); defer { lock.unlock() }
        guard let node = map[key] else { return nil }
        moveToHead(node)
        return node.value
    }

    /// Inserts or updates a value, evicting the LRU entry past capacity.
    func set(_ value: Value, forKey key: Key) {
        lock.lock(); defer { lock.unlock() }
        if let node = map[key] {
            node.value = value
            moveToHead(node)
            return
        }
        let node = Node(key: key, value: value)
        map[key] = node
        addToHead(node)
        if map.count > capacity {
            evictTail()
        }
    }

    func removeAll() {
        lock.lock(); defer { lock.unlock() }
        map.removeAll()
        head = nil
        tail = nil
    }

    subscript(key: Key) -> Value? {
        get { value(forKey: key) }
        set {
            if let newValue { set(newValue, forKey: key) }
        }
    }

    // MARK: - List maintenance (caller holds the lock)

    private func addToHead(_ node: Node) {
        node.prev = nil
        node.next = head
        head?.prev = node
        head = node
        if tail == nil { tail = node }
    }

    private func moveToHead(_ node: Node) {
        guard head !== node else { return }
        // Detach
        node.prev?.next = node.next
        node.next?.prev = node.prev
        if tail === node { tail = node.prev }
        // Re-attach at head
        addToHead(node)
    }

    private func evictTail() {
        guard let tailNode = tail else { return }
        map[tailNode.key] = nil
        tail = tailNode.prev
        tail?.next = nil
        if head === tailNode { head = nil }
    }
}
