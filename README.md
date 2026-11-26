# BF16 (Official Swift Package)

Official zero-dependency Swift Package for [bf16.ai](https://bf16.ai) — uncensored 1M-context open-weight LLM inference API (`DeepSeek V4.1 Flash`, `GLM-5.3`, `Kimi K3.1 Pro`) with strict Zero Data Retention (ZDR).

## Installation (SwiftPM)

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/BF16-AI/bf16-swift.git", from: "0.1.0")
]
```

## Quickstart

```swift
import BF16

let client = BF16Client(apiKey: ProcessInfo.processInfo.environment["BF16_API_KEY"])
let data = try await client.chat(BF16ChatRequest(
    model: BF16Client.modelDeepSeekV41Flash,
    messages: [BF16Message(role: "user", content: "Summarize this Swift package.")]
))
```

## Links

- Website & Console: [bf16.ai](https://bf16.ai)
- API Documentation: [bf16.ai/docs](https://bf16.ai/docs)
- Open-Source Grants (`$50` API credits): [bf16.ai/open-source](https://bf16.ai/open-source)
