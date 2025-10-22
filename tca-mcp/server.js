#!/usr/bin/env node

/**
 * TCA MCP Server for Cursor
 * Provides TCA documentation, code generation, linting, and analysis
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

// ============================================================================
// TCA DOCUMENTATION & PATTERNS
// ============================================================================

const TCA_RESOURCES = {
  'reducer-pattern': {
    title: 'Reducer Pattern',
    description: 'Core business logic pattern for TCA features',
    content: `# Reducer Pattern

The Reducer is the heart of TCA - it contains your feature's business logic.

## Structure

\`\`\`swift
@Reducer
struct CounterFeature {
  struct State: Equatable {
    var count = 0
  }
  
  enum Action {
    case increment
    case decrement
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .increment:
        state.count += 1
        return .none
      case .decrement:
        state.count -= 1
        return .none
      }
    }
  }
}
\`\`\`

## Key Concepts

- **State**: Immutable data structure representing feature state
- **Action**: Enum of all possible user/system interactions
- **Reduce**: Function that updates state based on actions
- **Effects**: Return .run { } for async operations

## Best Practices

1. Keep State flat and equatable
2. Make Actions specific and atomic
3. Never mutate state directly (TCA handles it)
4. Return .none for simple state updates
5. Use .run for side effects
`
  },

  'store-setup': {
    title: 'Store Setup',
    description: 'How to initialize and manage TCA stores',
    content: `# Store Setup

The Store is the runtime that powers your feature.

## Creating a Store

\`\`\`swift
let store = Store(initialState: CounterFeature.State()) {
  CounterFeature()
}
\`\`\`

## In SwiftUI (Modern TCA 1.0+)

\`\`\`swift
@main
struct MyApp: App {
  let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }
  
  var body: some Scene {
    WindowGroup {
      RootView(store: store)
    }
  }
}
\`\`\`

## Passing to Views

\`\`\`swift
struct ContentView: View {
  @Bindable var store: StoreOf<CounterFeature>
  
  var body: some View {
    VStack {
      Text("\\(store.count)")
      Button("Increment") { store.send(.increment) }
    }
  }
}
\`\`\`

## Key Points

- Store is generic over feature Reducer
- Pass .initialState and reducer closure
- Use @Bindable in views (TCA 1.0+)
- Store handles all state management
`
  },

  'effects-async': {
    title: 'Effects & Async',
    description: 'Handling side effects and async operations',
    content: `# Effects & Async Operations

Effects handle side effects like API calls, timers, and other async work.

## Basic Effect Pattern

\`\`\`swift
enum Action {
  case fetchUser
  case userResponse(Result<User, Error>)
}

var body: some ReducerOf<Self> {
  Reduce { state, action in
    switch action {
    case .fetchUser:
      state.isLoading = true
      return .run { send in
        let user = try await userClient.fetch()
        await send(.userResponse(.success(user)))
      } catch: { error, send in
        await send(.userResponse(.failure(error)))
      }
      
    case .userResponse(let result):
      state.isLoading = false
      state.user = try? result.get()
      return .none
    }
  }
}
\`\`\`

## Effect Types

- \`.none\` - No side effects
- \`.run\` - Async operation with error handling
- \`.send\` - Send multiple actions
- \`.merge\` - Combine multiple effects
- \`.cancel\` - Cancel running effects

## Dependencies

\`\`\`swift
@Dependency(\\.userClient) var userClient
\`\`\`

Use dependency injection for testability.
`
  },

  'navigation-stack': {
    title: 'Stack Navigation',
    description: 'Implement stack-based navigation with TCA',
    content: `# Stack Navigation

Push multiple screens onto a navigation stack.

## State Setup

\`\`\`swift
@Reducer
struct AppFeature {
  struct State: Equatable {
    var path = StackNavigationState<Path.State>()
  }
  
  @Reducer(state: .equatable)
  enum Path {
    case detail(DetailFeature)
    case edit(EditFeature)
  }
}
\`\`\`

## Actions

\`\`\`swift
enum Action {
  case path(StackAction<Path.State, Path.Action>)
}
\`\`\`

## Reducer

\`\`\`swift
var body: some ReducerOf<Self> {
  Reduce { state, action in
    // Handle root actions
    return .none
  }
  .forEach(\.path, action: \.path) {
    Path()
  }
}
\`\`\`

## View

\`\`\`swift
struct AppView: View {
  @Bindable var store: StoreOf<AppFeature>
  
  var body: some View {
    NavigationStack(
      path: $store.scope(state: \.path, action: \.path)
    ) { store in
      RootView()
    } destination: { store in
      switch store.state {
      case .detail:
        DetailView(store: store.scope(state: \.detail, action: \.detail))
      case .edit:
        EditView(store: store.scope(state: \.edit, action: \.edit))
      }
    }
  }
}
\`\`\`

## Key Features

- Multiple screens on back stack
- Type-safe navigation
- Full reducer control
- Automatic state management
`
  },

  'presentation-state': {
    title: 'Presentation State',
    description: 'Modal and sheet presentations with TCA',
    content: `# Presentation State

Handle modals and sheets with PresentationState.

## State

\`\`\`swift
@Reducer
struct AppFeature {
  struct State: Equatable {
    @PresentationState var detail: DetailFeature.State?
  }
  
  enum Action {
    case detail(PresentationAction<DetailFeature.Action>)
    case showDetail
    case dismissDetail
  }
}
\`\`\`

## Reducer

\`\`\`swift
var body: some ReducerOf<Self> {
  Reduce { state, action in
    switch action {
    case .showDetail:
      state.detail = DetailFeature.State()
      return .none
    case .dismissDetail:
      state.detail = nil
      return .none
    case .detail:
      return .none
    }
  }
  .ifLet(\.detail, action: \.detail) {
    DetailFeature()
  }
}
\`\`\`

## View

\`\`\`swift
.sheet(
  item: $store.scope(state: \.detail, action: \.detail)
) { store in
  DetailView(store: store)
}
\`\`\`

## Variants

- \`.sheet\` for sheets
- \`.fullScreenCover\` for full screen
- \`.popover\` for popovers
`
  },

  'testing': {
    title: 'Testing',
    description: 'Test TCA features with TestStore',
    content: `# Testing TCA Features

TCA makes testing straightforward with TestStore.

## Basic Test

\`\`\`swift
@MainActor
func testIncrement() async {
  let store = TestStore(
    initialState: CounterFeature.State(),
    reducer: { CounterFeature() }
  )
  
  await store.send(.increment) { state in
    state.count = 1
  }
}
\`\`\`

## Testing Effects

\`\`\`swift
func testFetchUser() async {
  let store = TestStore(
    initialState: AppFeature.State(),
    reducer: { AppFeature() }
  ) {
    $0.userClient = .testValue
  }
  
  await store.send(.fetchUser)
  
  await store.receive(\.userResponse) { state in
    state.user = .mock
  }
}
\`\`\`

## Key Features

- Verify exact state changes
- Assert on received actions
- Mock dependencies
- Time-travel debugging
- Deterministic testing

## Tips

1. Use @MainActor for UI tests
2. Test one action path at a time
3. Mock all external dependencies
4. Verify state diffs precisely
`
  },

  'tree-navigation': {
    title: 'Tree-Based Navigation',
    description: 'Hierarchical tree navigation with drill-down capabilities',
    content: `# Tree-Based Navigation

Tree navigation allows hierarchical drilling down through nested screens.

## Use Cases

- File browsers with nested folders
- Category → Subcategory → Item selection
- Multi-level menus
- Hierarchical list navigation

## State Setup

\`\`\`swift
@Reducer
struct TreeFeature {
  struct State: Equatable {
    var path = StackNavigationState<Path.State>()
    var items: [TreeItem] = []
  }
  
  @Reducer(state: .equatable)
  enum Path {
    case itemDetail(ItemDetailFeature)
    case subTree(SubTreeFeature)
  }
}

struct TreeItem: Identifiable, Equatable {
  let id: UUID
  var name: String
  var children: [TreeItem]?
}
\`\`\`

## Actions

\`\`\`swift
enum Action {
  case path(StackAction<Path.State, Path.Action>)
  case loadItems
  case drillDown(TreeItem)
  case popBack
}
\`\`\`

## Reducer

\`\`\`swift
var body: some ReducerOf<Self> {
  Reduce { state, action in
    switch action {
    case .loadItems:
      state.items = loadTreeData()
      return .none
      
    case .drillDown(let item):
      // Push new screen onto stack
      if item.children != nil {
        state.path.append(.subTree(SubTreeFeature.State(item: item)))
      } else {
        state.path.append(.itemDetail(ItemDetailFeature.State(item: item)))
      }
      return .none
      
    case .popBack:
      state.path.removeLast()
      return .none
      
    case .path:
      return .none
    }
  }
  .forEach(\.path, action: \.path) {
    Path()
  }
}
\`\`\`

## View

\`\`\`swift
struct TreeView: View {
  @Bindable var store: StoreOf<TreeFeature>
  
  var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) { store in
      List(store.items) { item in
        NavigationLink(value: item) {
          HStack {
            Image(systemName: item.children != nil ? "folder" : "doc")
            Text(item.name)
          }
        }
        .onTapGesture {
          store.send(.drillDown(item))
        }
      }
      .navigationTitle("Items")
    } destination: { store in
      switch store.state {
      case .itemDetail:
        ItemDetailView(store: store.scope(state: \.itemDetail, action: \.itemDetail))
      case .subTree:
        SubTreeView(store: store.scope(state: \.subTree, action: \.subTree))
      }
    }
  }
}
\`\`\`

## Key Differences vs Stack Navigation

| Aspect | Stack | Tree |
|--------|-------|------|
| Structure | Linear path | Hierarchical |
| Navigation | Push/Pop | Drill-down/Back |
| Data | Flat | Nested (recursive) |
| Use Case | Sequential screens | Hierarchical data |

## Tips

1. Use recursive data structures for tree items
2. Differentiate between leaf and branch items
3. Load children lazily for performance
4. Maintain path history for back navigation
5. Consider pagination for large trees
`
  }
};

// ============================================================================
// CODE GENERATION TEMPLATES
// ============================================================================

const CODE_TEMPLATES = {
  'counter': {
    description: 'Simple counter feature',
    code: `@Reducer
struct CounterFeature {
  struct State: Equatable {
    var count = 0
  }
  
  enum Action {
    case increment
    case decrement
    case reset
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .increment:
        state.count += 1
        return .none
      case .decrement:
        state.count -= 1
        return .none
      case .reset:
        state.count = 0
        return .none
      }
    }
  }
}

struct CounterView: View {
  @Bindable var store: StoreOf<CounterFeature>
  
  var body: some View {
    VStack(spacing: 20) {
      Text("\\(store.count)")
        .font(.largeTitle)
        .fontWeight(.bold)
      
      HStack(spacing: 16) {
        Button("-") { store.send(.decrement) }
        Button("Reset") { store.send(.reset) }
        Button("+") { store.send(.increment) }
      }
    }
    .padding()
  }
}`
  },

  'api-call': {
    description: 'API call with loading state',
    code: `@Reducer
struct UserFeature {
  struct State: Equatable {
    var user: User?
    var isLoading = false
    var error: String?
  }
  
  enum Action {
    case loadUser
    case userResponse(Result<User, Error>)
  }
  
  @Dependency(\.userClient) var userClient
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .loadUser:
        state.isLoading = true
        state.error = nil
        return .run { send in
          let user = try await userClient.fetchUser()
          await send(.userResponse(.success(user)))
        } catch: { error, send in
          await send(.userResponse(.failure(error)))
        }
        
      case .userResponse(let result):
        state.isLoading = false
        switch result {
        case .success(let user):
          state.user = user
          return .none
        case .failure(let error):
          state.error = error.localizedDescription
          return .none
        }
      }
    }
  }
}

struct UserView: View {
  @Bindable var store: StoreOf<UserFeature>
  
  var body: some View {
    VStack {
      if store.isLoading {
        ProgressView()
      } else if let user = store.user {
        Text(user.name)
      } else if let error = store.error {
        Text("Error: \\(error)")
      }
    }
    .onAppear { store.send(.loadUser) }
  }
}`
  },

  'list': {
    description: 'List with add/delete items',
    code: `@Reducer
struct ListFeature {
  struct State: Equatable {
    var items: IdentifiedArrayOf<Item> = []
  }
  
  enum Action {
    case addItem
    case removeItem(id: Item.ID)
    case itemUpdated(Item.ID, Item)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .addItem:
        state.items.append(Item(id: UUID(), title: "New Item"))
        return .none
        
      case .removeItem(let id):
        state.items.remove(id: id)
        return .none
        
      case .itemUpdated(let id, let item):
        state.items[id: id] = item
        return .none
      }
    }
  }
}

struct Item: Identifiable, Equatable {
  let id: UUID
  var title: String
}

struct ListView: View {
  @Bindable var store: StoreOf<ListFeature>
  
  var body: some View {
    List {
      ForEach(store.items) { item in
        Text(item.title)
      }
      .onDelete { offsets in
        offsets.forEach { index in
          store.send(.removeItem(id: store.items[index].id))
        }
      }
    }
    .toolbar {
      Button("Add") { store.send(.addItem) }
    }
  }
}`
  },

  'timer': {
    description: 'Timer with start/stop',
    code: `@Reducer
struct TimerFeature {
  struct State: Equatable {
    var seconds = 0
    var isRunning = false
  }
  
  enum Action {
    case startTimer
    case stopTimer
    case tick
  }
  
  @Dependency(\.continuousClock) var clock
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .startTimer:
        state.isRunning = true
        return .run { send in
          while true {
            try await clock.sleep(nanoseconds: 1_000_000_000)
            await send(.tick)
          }
        }
        .cancellable(id: "timer")
        
      case .stopTimer:
        state.isRunning = false
        return .cancel(id: "timer")
        
      case .tick:
        state.seconds += 1
        return .none
      }
    }
  }
}

struct TimerView: View {
  @Bindable var store: StoreOf<TimerFeature>
  
  var body: some View {
    VStack(spacing: 20) {
      Text("\\(store.seconds)s")
        .font(.largeTitle)
      
      if store.isRunning {
        Button("Stop") { store.send(.stopTimer) }
      } else {
        Button("Start") { store.send(.startTimer) }
      }
    }
  }
}`
  }
};

// ============================================================================
// LINTING & ANALYSIS
// ============================================================================

function lintSwiftCode(code) {
  const issues = [];
  
  // Check for State equatable conformance
  if (code.includes('struct State') && !code.includes('State: Equatable')) {
    issues.push({
      severity: 'error',
      message: 'State must conform to Equatable',
      line: 'State definition'
    });
  }
  
  // Check for mutable state in reducers
  if (code.includes('state.') && code.includes('state +=') || code.includes('state -=')) {
    // This is fine, TCA allows mutations
  }
  
  // Check for missing @Reducer annotation
  if (code.includes('struct') && code.includes('State:') && code.includes('enum Action') && !code.includes('@Reducer')) {
    issues.push({
      severity: 'warning',
      message: 'Consider adding @Reducer annotation for better performance',
      line: 'Reducer struct'
    });
  }
  
  // Check for unused actions
  const actionMatches = code.match(/case \.(\w+)/g) || [];
  const usedActions = new Set();
  
  // Check if all actions are handled
  if (code.includes('switch action') && actionMatches.length > 0) {
    const switchCases = code.match(/case \.\w+/g) || [];
    if (switchCases.length < actionMatches.length) {
      issues.push({
        severity: 'warning',
        message: 'Some actions may not be handled in the switch statement',
        line: 'Reduce closure'
      });
    }
  }
  
  return issues;
}

// ============================================================================
// MCP SERVER
// ============================================================================

class TCAServer {
  constructor() {
    this.server = new Server(
      {
        name: 'tca-cursor-mcp',
        version: '1.0.0',
      },
      {
        capabilities: {
          resources: {},
          tools: {},
        },
      }
    );

    this.setupHandlers();
  }

  setupHandlers() {
    // List Resources (documentation)
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      return {
        resources: Object.entries(TCA_RESOURCES).map(([key, doc]) => ({
          uri: `tca://docs/${key}`,
          name: doc.title,
          description: doc.description,
          mimeType: 'text/markdown'
        }))
      };
    });

    // Read Resource (documentation content)
    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const url = new URL(request.params.uri);
      const key = url.pathname.replace('/docs/', '');
      const doc = TCA_RESOURCES[key];
      
      if (!doc) {
        throw new Error(`Documentation not found: ${key}`);
      }

      return {
        contents: [{
          uri: request.params.uri,
          mimeType: 'text/markdown',
          text: doc.content
        }]
      };
    });

    // List Tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'get-tca-template',
            description: 'Get a code template for a TCA feature (counter, api-call, list, timer)',
            inputSchema: {
              type: 'object',
              properties: {
                template: {
                  type: 'string',
                  enum: ['counter', 'api-call', 'list', 'timer'],
                  description: 'Template name'
                }
              },
              required: ['template']
            }
          },
          {
            name: 'lint-tca-code',
            description: 'Analyze Swift TCA code for common issues',
            inputSchema: {
              type: 'object',
              properties: {
                code: {
                  type: 'string',
                  description: 'Swift code to lint'
                }
              },
              required: ['code']
            }
          },
          {
            name: 'search-tca-docs',
            description: 'Search TCA documentation by topic',
            inputSchema: {
              type: 'object',
              properties: {
                query: {
                  type: 'string',
                  description: 'Search topic (reducer, store, effects, navigation, presentation, testing)'
                }
              },
              required: ['query']
            }
          },
          {
            name: 'generate-reducer',
            description: 'Generate a basic TCA reducer scaffold',
            inputSchema: {
              type: 'object',
              properties: {
                name: {
                  type: 'string',
                  description: 'Feature name (e.g., Counter, User, Settings)'
                },
                hasEffects: {
                  type: 'boolean',
                  description: 'Include effect handling'
                }
              },
              required: ['name']
            }
          }
        ]
      };
    });

    // Call Tool
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      if (name === 'get-tca-template') {
        const template = CODE_TEMPLATES[args.template];
        if (!template) {
          return {
            content: [{ type: 'text', text: `Unknown template: ${args.template}` }]
          };
        }
        return {
          content: [{
            type: 'text',
            text: `# ${template.description}\n\n\`\`\`swift\n${template.code}\n\`\`\``
          }]
        };
      }

      if (name === 'lint-tca-code') {
        const issues = lintSwiftCode(args.code);
        const report = issues.length > 0
          ? issues.map(i => `[${i.severity.toUpperCase()}] ${i.message} (${i.line})`).join('\n')
          : '✅ No issues found!';
        
        return {
          content: [{
            type: 'text',
            text: `# Lint Report\n\n${report}`
          }]
        };
      }

      if (name === 'search-tca-docs') {
        const query = args.query.toLowerCase();
        const matches = Object.entries(TCA_RESOURCES).filter(([key, doc]) =>
          key.includes(query) || doc.title.toLowerCase().includes(query) || doc.description.toLowerCase().includes(query)
        );

        if (matches.length === 0) {
          return {
            content: [{ type: 'text', text: `No documentation found for "${query}"` }]
          };
        }

        const links = matches.map(([key, doc]) => `- [${doc.title}](tca://docs/${key})`).join('\n');
        return {
          content: [{
            type: 'text',
            text: `# TCA Documentation\n\nFound ${matches.length} matches:\n\n${links}`
          }]
        };
      }

      if (name === 'generate-reducer') {
        const name = args.name;
        const hasEffects = args.hasEffects || false;

        let code = `@Reducer
struct ${name}Feature {
  struct State: Equatable {
    // Add your state properties here
  }
  
  enum Action {
    // Add your actions here
  }
  
  `;

        if (hasEffects) {
          code += `@Dependency(\.someClient) var someClient
  
  `;
        }

        code += `var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      // Handle actions here
      }
    }
  }
}`;

        return {
          content: [{
            type: 'text',
            text: `# Generated Reducer\n\n\`\`\`swift\n${code}\n\`\`\``
          }]
        };
      }

      throw new Error(`Unknown tool: ${name}`);
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

const server = new TCAServer();
server.run().catch(console.error);

