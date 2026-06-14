import Foundation

public struct TGNNEstimatorConfig: Codable, Sendable {
    public var nodeIn: Int
    public var edgeIn: Int
    public var hidden: Int
    public var heads: Int

    public init(nodeIn: Int, edgeIn: Int, hidden: Int = 128, heads: Int = 4) {
        self.nodeIn = nodeIn
        self.edgeIn = edgeIn
        self.hidden = hidden
        self.heads = heads
    }
}

public struct TGNNEstimatorSwift: Codable, Sendable {
    public var config: TGNNEstimatorConfig
    public var nodeProjection: [Double]
    public var edgeProjection: [Double]
    public var attentionWeights: [Double]
    public var mlpWeights: [Double]
    public var mlpBiases: [Double]

    public init(config: TGNNEstimatorConfig) {
        self.config = config
        let nodeOut = config.hidden * config.heads
        self.nodeProjection = Self.randomVector(count: config.nodeIn * nodeOut, scale: 0.05)
        self.edgeProjection = Self.randomVector(count: config.edgeIn * nodeOut, scale: 0.05)
        self.attentionWeights = Self.randomVector(count: nodeOut * 2, scale: 0.05)
        self.mlpWeights = Self.randomVector(count: nodeOut * nodeOut + nodeOut + nodeOut, scale: 0.05)
        self.mlpBiases = Self.randomVector(count: nodeOut + 1, scale: 0.01)
    }

    public mutating func predictLogPrice(graph: TrainingGraphSwift) -> Double {
        var nodeEmbeddings = graph.nodeFeatures.map { projectNode($0) }
        for _ in 0..<2 {
            nodeEmbeddings = transformerLayer(
                nodes: nodeEmbeddings,
                edgeIndex: graph.edgeIndex,
                edgeAttributes: graph.edgeAttributes
            )
        }
        return mlpHead(nodeEmbeddings[0])
    }

    public mutating func trainStep(graph: TrainingGraphSwift, learningRate: Double) -> Double {
        let prediction = predictLogPrice(graph: graph)
        let target = graph.targets[0]
        let error = prediction - target
        let loss = error * error
        applyGradient(error: error, learningRate: learningRate)
        return loss
    }

    private mutating func projectNode(_ features: [Double]) -> [Double] {
        matvec(
            weights: nodeProjection,
            input: features,
            rows: config.hidden * config.heads,
            cols: config.nodeIn
        )
    }

    private mutating func projectEdge(_ features: [Double]) -> [Double] {
        matvec(
            weights: edgeProjection,
            input: features,
            rows: config.hidden * config.heads,
            cols: config.edgeIn
        )
    }

    private mutating func transformerLayer(
        nodes: [[Double]],
        edgeIndex: [[Int]],
        edgeAttributes: [[Double]]
    ) -> [[Double]] {
        var updated = nodes
        let hiddenSize = config.hidden * config.heads

        for edgePosition in edgeIndex.indices {
            let source = edgeIndex[edgePosition][0]
            let target = edgeIndex[edgePosition][1]
            guard source < nodes.count, target < nodes.count else { continue }

            let edgeEmbedding = projectEdge(edgeAttributes[edgePosition])
            let combined = zip(nodes[source], edgeEmbedding).map(+)
            let score = dot(combined + nodes[target], attentionWeights)
            let weight = 1.0 / (1.0 + exp(-score))

            for index in 0..<hiddenSize {
                updated[target][index] += weight * combined[index] / Double(config.heads)
            }
        }

        return updated.map { tanhVector($0) }
    }

    private mutating func mlpHead(_ embedding: [Double]) -> Double {
        let hiddenSize = config.hidden * config.heads
        let hidden = tanhVector(
            matvec(
                weights: Array(mlpWeights.prefix(hiddenSize * hiddenSize)),
                input: embedding,
                rows: hiddenSize,
                cols: hiddenSize,
                bias: Array(mlpBiases.prefix(hiddenSize))
            )
        )
        let output = dot(
            hidden,
            Array(mlpWeights.suffix(hiddenSize))
        ) + (mlpBiases.last ?? 0)
        return output
    }

    private mutating func applyGradient(error: Double, learningRate: Double) {
        let delta = 2 * error * learningRate
        nodeProjection = nodeProjection.map { $0 - delta * 0.001 }
        edgeProjection = edgeProjection.map { $0 - delta * 0.001 }
        attentionWeights = attentionWeights.map { $0 - delta * 0.001 }
        mlpWeights = mlpWeights.map { $0 - delta * 0.001 }
        mlpBiases = mlpBiases.map { $0 - delta * 0.001 }
    }

    private static func randomVector(count: Int, scale: Double) -> [Double] {
        (0..<count).map { _ in Double.random(in: -scale...scale) }
    }
}

private func matvec(
    weights: [Double],
    input: [Double],
    rows: Int,
    cols: Int,
    bias: [Double] = []
) -> [Double] {
    var output = Array(repeating: 0.0, count: rows)
    for row in 0..<rows {
        var sum = row < bias.count ? bias[row] : 0
        for col in 0..<cols {
            sum += weights[row * cols + col] * input[col]
        }
        output[row] = sum
    }
    return output
}

private func dot(_ lhs: [Double], _ rhs: [Double]) -> Double {
    zip(lhs, rhs).reduce(0) { $0 + $1.0 * $1.1 }
}

private func tanhVector(_ values: [Double]) -> [Double] {
    values.map { tanh($0) }
}
