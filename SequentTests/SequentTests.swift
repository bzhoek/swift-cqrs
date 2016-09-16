import XCTest
@testable import Sequent

class Identifiable: Equatable {
  let uuid: String
  init(uuid: String) {
    self.uuid = uuid
  }

  var description: String {
    return "uuid:\(uuid)"
  }
}

func ==(lhs: Identifiable, rhs: Identifiable) -> Bool {return lhs.description == rhs.description}

class Command: Identifiable {
}

class Event: Identifiable {
}

func ==(lhs: Event, rhs: Event) -> Bool {return lhs.uuid == rhs.uuid}

class CommandBus {
  let handlers: [CommandHandler]

  init(handlers: [CommandHandler]) {
    self.handlers = handlers
  }

  func dispatch(command: Command) {
    handlers.map {
      $0.handle(command)
    }.flatMap {
      $0
    }
  }

  func emit(events: [Event]) {

  }
}

class EventBus {
  var events: [Event] = []

  init() {
  }

  func add(event: Event) {
    events.append(event)
  }
}

class CommandHandler {
  let bus: EventBus
  let store: EventStore

  init(bus: EventBus, store: EventStore) {
    self.bus = bus
    self.store = store
  }

  func handle(command: Command) -> [Event]? {
    return .None
  }

  func emit(event: Event) { bus.add(event) }
}

class CommandBusTests: XCTestCase {

  class MockCommandHandler: CommandHandler {
    override func handle(command: Command) -> [Event]? {
      return []
    }
  }

  func testCommandBus() {
    let bus = CommandBus(handlers: [MockCommandHandler(bus: EventBus(), store: EventStore())])
    let command = Command(uuid: "1")
    bus.dispatch(command)
  }
}

class Aggregate {
  let bus: EventBus
  init(bus: EventBus) {
    self.bus = bus
  }
  
  func emit(event: Event) {
    bus.add(event)
  }
}

class EventStore {
  var eventsMap = [String: [Event]]()
  
  func add(events: [Event]) {
    for event in events {
      if eventsMap[event.uuid] == nil {
        eventsMap[event.uuid] = [event]
      } else {
        eventsMap[event.uuid]?.append(event)
      }
    }
  }
  
  func lookup(uuid: String) -> [Event]? {
    return eventsMap[uuid]
  }
}

class SequentTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testCommandUUID() {
    let command = Command(uuid: "test")
    XCTAssertEqual("test", command.uuid)
  }

}

class EventStoreTests: XCTestCase {

  func testLookup() {
    let eventStore = EventStore()
    eventStore.add([TodoCreated(uuid: "1", title: "Title", body: "Body")])
    XCTAssertEqual(1, eventStore.lookup("1")?.count)
  }
  
}

