import ArgumentParser
import Foundation
import TGNNCore

@main
struct SwiftTrainTGNN: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Train the Chapter 10 T-GNN entirely in Swift."
    )

    @Option(name: .long, help: "Path to the transaction CSV file.")
    var data: String

    @Option(name: .long, help: "Training split start date (yyyy-MM-dd).")
    var trainStart: String = "2018-01-01"

    @Option(name: .long, help: "Training split end date (yyyy-MM-dd).")
    var trainEnd: String = "2020-12-31"

    @Option(name: .long, help: "Test split start date (yyyy-MM-dd).")
    var testStart: String = "2021-01-01"

    @Option(name: .long, help: "Test split end date (yyyy-MM-dd).")
    var testEnd: String = "2021-12-31"

    @Option(name: .long, help: "KNN neighbors per subject node.")
    var k: Int = 200

    @Option(name: .long, help: "Hidden dimension size.")
    var hidden: Int = 128

    @Option(name: .long, help: "Attention head count.")
    var heads: Int = 4

    @Option(name: .long, help: "Training epochs.")
    var epochs: Int = 30

    @Option(name: .long, help: "Learning rate for the simplified update rule.")
    var learningRate: Double = 0.01

    @Option(name: .long, help: "Output weights JSON path.")
    var output: String = "swift_tgnn_weights.json"

    mutating func run() async throws {
        let dataURL = URL(fileURLWithPath: data)
        let transactions = try loadTransactionsFromCSV(url: dataURL)
        let splits = splitTransactionsByDate(
            transactions: transactions,
            trainStart: trainStart,
            trainEnd: trainEnd,
            testStart: testStart,
            testEnd: testEnd
        )

        guard !splits.train.isEmpty else {
            throw ValidationError("No training rows found for \(trainStart)...\(trainEnd).")
        }

        print("Loaded \(transactions.count) rows (\(splits.train.count) train, \(splits.test.count) test)")

        let trainDataset = preprocessTransactionsSwift(transactions: splits.train)
        let testDataset = preprocessTransactionsSwift(
            transactions: splits.test,
            priorTransactions: splits.train,
            stats: trainDataset.stats
        )

        let trainGraphs = buildTrainingGraphSwift(dataset: trainDataset, k: k)
        let testGraphs = buildTrainingGraphSwift(dataset: testDataset, k: k)

        guard let sampleGraph = trainGraphs.first else {
            throw ValidationError("Unable to build training graphs.")
        }

        var model = TGNNEstimatorSwift(
            config: TGNNEstimatorConfig(
                nodeIn: sampleGraph.nodeFeatures[0].count,
                edgeIn: sampleGraph.edgeAttributes.first?.count ?? 2,
                hidden: hidden,
                heads: heads
            )
        )

        print("Training \(trainGraphs.count) subject graphs for \(epochs) epochs...")
        for epoch in 1...epochs {
            var epochLoss = 0.0
            for graphIndex in trainGraphs.indices.shuffled() {
                epochLoss += model.trainStep(graph: trainGraphs[graphIndex], learningRate: learningRate)
            }
            let averageLoss = epochLoss / Double(trainGraphs.count)
            print(String(format: "Epoch %02d | train MSE(log price): %.6f", epoch, averageLoss))
        }

        if !testGraphs.isEmpty {
            var predictions: [Double] = []
            var actuals: [Double] = []
            predictions.reserveCapacity(testGraphs.count)
            actuals.reserveCapacity(testGraphs.count)

            for graph in testGraphs {
                predictions.append(model.predictLogPrice(graph: graph))
                actuals.append(graph.targets[0])
            }

            let metrics = evaluatePredictions(
                actualLogPrices: actuals,
                predictedLogPrices: predictions
            )

            print("\nTest metrics (§10.3):")
            print(String(format: "R²=%.4f MAE=%.2f MdAE=%.2f MAPE=%.2f%% MdAPE=%.2f%% MPE=%.2f%% MdPE=%.2f%%",
                           metrics.r2, metrics.mae, metrics.mdae, metrics.mape, metrics.mdape, metrics.mpe, metrics.mdpe))
        }

        let outputURL = URL(fileURLWithPath: output)
        try saveModelWeights(model, to: outputURL)
        print("Saved weights to \(outputURL.path)")
    }
}
