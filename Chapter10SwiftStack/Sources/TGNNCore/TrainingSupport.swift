import Foundation

public struct EvaluationMetricsSwift: Sendable {
    public var r2: Double
    public var mae: Double
    public var mdae: Double
    public var mape: Double
    public var mdape: Double
    public var mpe: Double
    public var mdpe: Double

    public init(
        r2: Double,
        mae: Double,
        mdae: Double,
        mape: Double,
        mdape: Double,
        mpe: Double,
        mdpe: Double
    ) {
        self.r2 = r2
        self.mae = mae
        self.mdae = mdae
        self.mape = mape
        self.mdape = mdape
        self.mpe = mpe
        self.mdpe = mdpe
    }
}

public func loadTransactionsFromCSV(url: URL) throws -> [[String: String]] {
    let text = try String(contentsOf: url, encoding: .utf8)
    let lines = text.split(whereSeparator: \.isNewline).map(String.init)
    guard let headerLine = lines.first else { return [] }

    let headers = parseCSVRow(headerLine)
    var rows: [[String: String]] = []
    rows.reserveCapacity(lines.count - 1)

    for line in lines.dropFirst() where !line.isEmpty {
        let values = parseCSVRow(line)
        guard values.count == headers.count else { continue }
        var row: [String: String] = [:]
        for (header, value) in zip(headers, values) {
            row[header] = value
        }
        rows.append(row)
    }

    return rows
}

public func splitTransactionsByDate(
    transactions: [[String: String]],
    trainStart: String,
    trainEnd: String,
    testStart: String,
    testEnd: String
) -> (train: [[String: String]], test: [[String: String]]) {
    guard let trainStartDate = parseDate(trainStart),
          let trainEndDate = parseDate(trainEnd),
          let testStartDate = parseDate(testStart),
          let testEndDate = parseDate(testEnd) else {
        return ([], [])
    }

    var train: [[String: String]] = []
    var test: [[String: String]] = []

    for row in transactions {
        guard let date = parseDate(row["timestamp"] ?? row["date"]) else { continue }
        if date >= trainStartDate && date <= trainEndDate {
            train.append(row)
        } else if date >= testStartDate && date <= testEndDate {
            test.append(row)
        }
    }

    return (train, test)
}

public func evaluatePredictions(
    actualLogPrices: [Double],
    predictedLogPrices: [Double]
) -> EvaluationMetricsSwift {
    let count = min(actualLogPrices.count, predictedLogPrices.count)
    guard count > 0 else {
        return EvaluationMetricsSwift(
            r2: 0, mae: 0, mdae: 0, mape: 0, mdape: 0, mpe: 0, mdpe: 0
        )
    }

    let actual = actualLogPrices.prefix(count).map(exp)
    let predicted = predictedLogPrices.prefix(count).map(exp)

    let actualMean = actual.reduce(0, +) / Double(count)
    let ssTot = actual.reduce(0) { $0 + pow($1 - actualMean, 2) }
    let ssRes = zip(actual, predicted).reduce(0) { $0 + pow($1.0 - $1.1, 2) }
    let r2 = ssTot > 0 ? 1 - (ssRes / ssTot) : 0

    let absErrors = zip(actual, predicted).map { abs($0.0 - $0.1) }
    let pctErrors = zip(actual, predicted).map { ($0.1 - $0.0) / max($0.0, 1) * 100 }

    return EvaluationMetricsSwift(
        r2: r2,
        mae: mean(absErrors),
        mdae: median(absErrors),
        mape: mean(pctErrors.map(abs)),
        mdape: median(pctErrors.map(abs)),
        mpe: mean(pctErrors),
        mdpe: median(pctErrors)
    )
}

public func saveModelWeights(_ model: TGNNEstimatorSwift, to url: URL) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(model)
    try data.write(to: url, options: .atomic)
}

public func loadModelWeights(from url: URL) throws -> TGNNEstimatorSwift {
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(TGNNEstimatorSwift.self, from: data)
}

private func parseCSVRow(_ line: String) -> [String] {
    line.split(separator: ",", omittingEmptySubsequences: false).map {
        $0.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private func mean(_ values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    return values.reduce(0, +) / Double(values.count)
}

private func median(_ values: [Double]) -> Double {
    let sorted = values.sorted()
    guard !sorted.isEmpty else { return 0 }
    return sorted[sorted.count / 2]
}
