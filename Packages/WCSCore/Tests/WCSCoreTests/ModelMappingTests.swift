import XCTest
@testable import WCSCore

final class ModelMappingTests: XCTestCase {
    func testProfileMapping() {
        let id = UUID()
        let dto = ProfileDTO(id: id, full_name: "Jane Doe", preferred_name: "Mum", birth_year: 1944, diagnosis_notes: nil, primary_language: "en")
        let model = PersonProfile(dto: dto)
        XCTAssertEqual(model.id, id)
        XCTAssertEqual(model.fullName, "Jane Doe")
        XCTAssertEqual(model.preferredName, "Mum")
        XCTAssertEqual(model.birthYear, 1944)
    }
}
