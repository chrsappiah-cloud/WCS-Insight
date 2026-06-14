import TGNNCore
import Vapor

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        defer { app.shutdown() }

        try routes(app)
        try await app.execute()
    }
}

func routes(_ app: Application) throws {
    app.post("valuation", "simulate") { req async throws -> ValuationResponse in
        let payload = try req.content.decode(ValuationRequest.self)
        let model = try loadProductionModel(app: app)
        let graph = try buildSimulationGraph(request: payload, app: app)

        var mutableModel = model
        let logPrice = mutableModel.predictLogPrice(graph: graph)
        return ValuationResponse(
            estimatedPrice: exp(logPrice),
            logPrice: logPrice,
            neighborCount: max(graph.edgeIndex.count, 0)
        )
    }

    app.get("health") { _ in
        ["status": "ok"]
    }
}

struct ValuationRequest: Content {
    var bedrooms: Double
    var bathrooms: Double
    var sqft: Double
    var lotSize: Double
    var yearBuilt: Double
    var city: String
    var zip: String
    var timestamp: String
}

struct ValuationResponse: Content {
    var estimatedPrice: Double
    var logPrice: Double
    var neighborCount: Int
}

private func loadProductionModel(app: Application) throws -> TGNNEstimatorSwift {
    if let url = Bundle.module.url(forResource: "swift_tgnn_weights", withExtension: "json"),
       FileManager.default.fileExists(atPath: url.path) {
        return try loadModelWeights(from: url)
    }

    app.logger.warning("No saved weights found; using freshly initialized model.")
    return TGNNEstimatorSwift(
        config: TGNNEstimatorConfig(nodeIn: 11, edgeIn: 13, hidden: 128, heads: 4)
    )
}

private func buildSimulationGraph(
    request: ValuationRequest,
    app: Application
) throws -> TrainingGraphSwift {
    guard let csvURL = Bundle.module.url(forResource: "king_county_sample", withExtension: "csv") else {
        throw Abort(.internalServerError, reason: "Sample dataset missing from bundle.")
    }

    let transactions = try loadTransactionsFromCSV(url: csvURL)
    let trainDataset = preprocessTransactionsSwift(transactions: transactions)

    let subjectRow: [String: String] = [
        "bedrooms": String(request.bedrooms),
        "bathrooms": String(request.bathrooms),
        "sqft": String(request.sqft),
        "lot_size": String(request.lotSize),
        "year_built": String(request.yearBuilt),
        "city": request.city,
        "zip": request.zip,
        "price": "650000",
        "timestamp": request.timestamp
    ]

    var combinedRows = transactions
    combinedRows.append(subjectRow)

    let combinedDataset = preprocessTransactionsSwift(
        transactions: combinedRows,
        priorTransactions: transactions,
        stats: trainDataset.stats
    )

    guard let graph = buildTrainingGraphSwift(dataset: combinedDataset, k: 200).last else {
        throw Abort(.internalServerError, reason: "Unable to build simulation graph.")
    }

    return graph
}
