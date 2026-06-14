import Foundation

public struct PreprocessingStatsSwift: Codable, Sendable {
    public var featureNames: [String]
    public var medians: [Double]
    public var means: [Double]
    public var stds: [Double]
    public var cityPriorCounts: [String: Double]
    public var cityPriorTotals: [String: Double]

    public init(
        featureNames: [String],
        medians: [Double],
        means: [Double],
        stds: [Double],
        cityPriorCounts: [String: Double] = [:],
        cityPriorTotals: [String: Double] = [:]
    ) {
        self.featureNames = featureNames
        self.medians = medians
        self.means = means
        self.stds = stds
        self.cityPriorCounts = cityPriorCounts
        self.cityPriorTotals = cityPriorTotals
    }
}

public struct PreprocessedDatasetSwift: Sendable {
    public var features: [[Double]]
    public var logPrices: [Double]
    public var timestamps: [Date]
    public var stats: PreprocessingStatsSwift

    public init(
        features: [[Double]],
        logPrices: [Double],
        timestamps: [Date],
        stats: PreprocessingStatsSwift
    ) {
        self.features = features
        self.logPrices = logPrices
        self.timestamps = timestamps
        self.stats = stats
    }
}

public struct TrainingGraphSwift: Sendable {
    public var nodeFeatures: [[Double]]
    public var edgeIndex: [[Int]]
    public var edgeAttributes: [[Double]]
    public var targets: [Double]

    public init(
        nodeFeatures: [[Double]],
        edgeIndex: [[Int]],
        edgeAttributes: [[Double]],
        targets: [Double]
    ) {
        self.nodeFeatures = nodeFeatures
        self.edgeIndex = edgeIndex
        self.edgeAttributes = edgeAttributes
        self.targets = targets
    }
}

private let numericFeatureKeys = [
    "bedrooms", "bathrooms", "sqft", "lot_size", "year_built", "price"
]

private let logTransformKeys: Set<String> = ["price", "sqft", "lot_size"]

public func preprocessTransactionsSwift(
    transactions: [[String: String]],
    priorTransactions: [[String: String]]? = nil,
    stats: PreprocessingStatsSwift? = nil
) -> PreprocessedDatasetSwift {
    let prior = priorTransactions ?? transactions
    var cityCounts: [String: Double] = stats?.cityPriorCounts ?? [:]
    var cityTotals: [String: Double] = stats?.cityPriorTotals ?? [:]

    if stats == nil {
        for row in prior {
            guard let city = row["city"], let price = parseDouble(row["price"]) else { continue }
            cityCounts[city, default: 0] += 1
            cityTotals[city, default: 0] += log(price)
        }
    }

    var rawRows: [[Double]] = []
    var logPrices: [Double] = []
    var timestamps: [Date] = []

    for row in transactions {
        guard let timestamp = parseDate(row["timestamp"] ?? row["date"]),
              let price = parseDouble(row["price"]) else { continue }

        var vector: [Double] = []
        for key in numericFeatureKeys where key != "price" {
            let value = parseDouble(row[key]) ?? 0
            vector.append(logTransformKeys.contains(key) ? log(max(value, 1)) : value)
        }

        if let city = row["city"] {
            let count = cityCounts[city, default: 1]
            let total = cityTotals[city, default: log(price)]
            vector.append(total / count)
        } else {
            vector.append(0)
        }

        if let zip = row["zip"] {
            vector.append(Double(zip.hashValue % 997) / 997.0)
        } else {
            vector.append(0)
        }

        let month = Calendar.current.component(.month, from: timestamp)
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: timestamp) ?? 1
        vector.append(sin(2 * Double.pi * Double(month) / 12.0))
        vector.append(cos(2 * Double.pi * Double(month) / 12.0))
        vector.append(sin(2 * Double.pi * Double(dayOfYear) / 365.0))
        vector.append(cos(2 * Double.pi * Double(dayOfYear) / 365.0))

        rawRows.append(vector)
        logPrices.append(log(max(price, 1)))
        timestamps.append(timestamp)
    }

    let featureNames = (numericFeatureKeys.filter { $0 != "price" } + ["city_prior_log_price", "zip_hash", "month_sin", "month_cos", "doy_sin", "doy_cos"])
    let columnCount = rawRows.first?.count ?? 0
    var medians = stats?.medians ?? Array(repeating: 0.0, count: columnCount)
    var means = stats?.means ?? Array(repeating: 0.0, count: columnCount)
    var stds = stats?.stds ?? Array(repeating: 1.0, count: columnCount)

    if stats == nil {
        for column in 0..<columnCount {
            let values = rawRows.map { $0[column] }.sorted()
            medians[column] = values.isEmpty ? 0 : values[values.count / 2]
        }
        for rowIndex in rawRows.indices {
            for column in 0..<columnCount where rawRows[rowIndex][column].isNaN {
                rawRows[rowIndex][column] = medians[column]
            }
        }
        for column in 0..<columnCount {
            let values = rawRows.map { $0[column] }
            means[column] = mean(values)
            stds[column] = max(std(values, mean: means[column]), 1e-6)
        }
    } else {
        for rowIndex in rawRows.indices {
            for column in 0..<columnCount where rawRows[rowIndex][column].isNaN {
                rawRows[rowIndex][column] = medians[column]
            }
        }
    }

    let normalized = rawRows.map { row in
        zip(row, zip(means, stds)).map { value, pair in
            (value - pair.0) / pair.1
        }
    }

    let outputStats = PreprocessingStatsSwift(
        featureNames: featureNames,
        medians: medians,
        means: means,
        stds: stds,
        cityPriorCounts: cityCounts,
        cityPriorTotals: cityTotals
    )

    return PreprocessedDatasetSwift(
        features: normalized,
        logPrices: logPrices,
        timestamps: timestamps,
        stats: outputStats
    )
}

public func buildTrainingGraphSwift(
    dataset: PreprocessedDatasetSwift,
    k: Int = 200
) -> [TrainingGraphSwift] {
    let count = dataset.features.count
    guard count > 0 else { return [] }

    var graphs: [TrainingGraphSwift] = []
    graphs.reserveCapacity(count)

    for subjectIndex in 0..<count {
        let subjectTime = dataset.timestamps[subjectIndex]
        let subjectFeatures = dataset.features[subjectIndex]

        var candidates: [(index: Int, distance: Double)] = []
        candidates.reserveCapacity(subjectIndex)

        for neighborIndex in 0..<subjectIndex {
            let neighborTime = dataset.timestamps[neighborIndex]
            guard neighborTime <= subjectTime else { continue }
            let distance = euclideanDistance(subjectFeatures, dataset.features[neighborIndex])
            candidates.append((neighborIndex, distance))
        }

        candidates.sort { $0.distance < $1.distance }
        let selected = Array(candidates.prefix(min(k, candidates.count)))

        var nodeFeatures: [[Double]] = [subjectFeatures]
        var edgeIndex: [[Int]] = []
        var edgeAttributes: [[Double]] = []

        for (rank, candidate) in selected.enumerated() {
            let neighborIndex = candidate.index
            nodeFeatures.append(dataset.features[neighborIndex])

            let timeGap = subjectTime.timeIntervalSince(dataset.timestamps[neighborIndex]) / 86_400.0
            let deltas = zip(subjectFeatures, dataset.features[neighborIndex]).map(-)
            edgeIndex.append([rank + 1, 0])
            edgeAttributes.append([candidate.distance, timeGap] + deltas)
        }

        graphs.append(
            TrainingGraphSwift(
                nodeFeatures: nodeFeatures,
                edgeIndex: edgeIndex,
                edgeAttributes: edgeAttributes,
                targets: [dataset.logPrices[subjectIndex]]
            )
        )
    }

    return graphs
}

public func parseDouble(_ value: String?) -> Double? {
    guard let value, !value.isEmpty else { return nil }
    return Double(value)
}

public func parseDate(_ value: String?) -> Date? {
    guard let value, !value.isEmpty else { return nil }
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate]
    if let date = formatter.date(from: value) { return date }
    let fallback = DateFormatter()
    fallback.locale = Locale(identifier: "en_US_POSIX")
    fallback.dateFormat = "yyyy-MM-dd"
    return fallback.date(from: value)
}

private func mean(_ values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    return values.reduce(0, +) / Double(values.count)
}

private func std(_ values: [Double], mean: Double) -> Double {
    guard values.count > 1 else { return 1 }
    let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count - 1)
    return sqrt(variance)
}

private func euclideanDistance(_ lhs: [Double], _ rhs: [Double]) -> Double {
    sqrt(zip(lhs, rhs).reduce(0) { $0 + pow($1.0 - $1.1, 2) })
}
