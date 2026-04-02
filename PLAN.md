# Part 1: Core Concurrency Actors & Macro-Driven Dependency Injection

## What This Part Delivers

The architectural foundation for Fast Fill Browser: custom concurrency actors, the Point-Free `swift-dependencies` package, and strict protocol interfaces for the three core services — all added **alongside** the existing working code (no breaking changes).

---

### **Features**

- **Two custom global actors** (`@WebKitConfigActor` and `@TabIsolationActor`) for isolating WebKit configuration and tab state onto dedicated serial executors
- **Point-Free swift-dependencies package** installed via SPM, providing `@DependencyClient`, `@DependencyEndpoint`, and `@Dependency` macros
- **Three service protocol interfaces** defined as `@DependencyClient` structs:
  - `KeychainClient` — save, retrieve, batch-retrieve, and delete passwords (all `async throws`, `Sendable`)
  - `BiometricClient` — check availability, authenticate, lock (all `async throws`, `Sendable`)
  - `JavaScriptInjectionClient` — generate fill scripts, detect login forms, extract credentials (all `Sendable`)
- **Dependency registration** in `DependencyValues` so any ViewModel can later use `@Dependency(\.keychainClient)` etc.
- **Typed error enums** (`KeychainError`, `BiometricError`) marked `nonisolated` and `Sendable`

### **Files Created**

### **What Stays Untouched**

- All existing Views, ViewModels, Models, and Services remain as-is
- The app continues to work exactly as before
- Concrete service wiring and migration happens in a future part

### **Package Installed**

- `swift-dependencies` (v1.0.0+) from Point-Free — provides `@DependencyClient`, `@DependencyEndpoint`, `@Dependency`, and `DependencyValues`

