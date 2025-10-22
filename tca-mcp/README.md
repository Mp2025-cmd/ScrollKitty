# TCA MCP Server for Cursor

A comprehensive Model Context Protocol (MCP) server providing Swift Composable Architecture (TCA) documentation, code generation, and linting tools integrated with Cursor.

## Features

✨ **What You Get:**

- 📚 **Complete TCA Documentation**: Reducer patterns, Store setup, Effects, Navigation, Presentation, Testing
- 🧬 **Code Generation**: Generate TCA reducer scaffolds with just a name
- 📋 **Code Templates**: Counter, API call, List management, Timer examples
- 🔍 **Linting & Analysis**: Detect common TCA mistakes in real-time
- 🎯 **4 Powerful Tools**:
  - `get-tca-template` - Ready-to-use code templates
  - `lint-tca-code` - Analyze Swift TCA code
  - `search-tca-docs` - Find TCA documentation topics
  - `generate-reducer` - Scaffold new features

## Installation

### 1. Install Dependencies

```bash
cd /Users/peter/Desktop/ScrollKitty/tca-mcp
npm install
```

### 2. Configure in Cursor

Open **Cursor Settings** → **Features** → **MCP**

Click **"+ Add New MCP Server"** and enter:

**Name:** `tca-mcp`

**Transport:** `stdio`

**Command:** `node`

**Arguments:** `/Users/peter/Desktop/ScrollKitty/tca-mcp/server.js`

**Working Directory:** `/Users/peter/Desktop/ScrollKitty/tca-mcp`

Click **Add**.

### 3. Restart Cursor

Close and reopen Cursor to load the MCP server.

## Usage

Once configured, use the MCP tools in Cursor's Chat/Composer:

### Get a Template

**Ask Cursor:**
> Generate a counter feature using TCA

**Cursor will use:** `get-tca-template` with `counter`

### Lint Your Code

**Ask Cursor:**
> Check this TCA code for issues: [paste your code]

**Cursor will use:** `lint-tca-code` to analyze

### Find Documentation

**Ask Cursor:**
> How do I use effects in TCA?

**Cursor will use:** `search-tca-docs` for `effects`

### Generate Scaffolding

**Ask Cursor:**
> Generate a reducer for a User feature with API calls

**Cursor will use:** `generate-reducer` with `User` and `hasEffects: true`

## Documentation Topics

The server provides documentation for:

- **reducer-pattern** - Core business logic structure
- **store-setup** - Initialize and manage stores
- **effects-async** - Handle side effects and async
- **navigation-stack** - Stack-based navigation
- **presentation-state** - Modals and sheets
- **testing** - Test TCA with TestStore

## Tools Reference

### get-tca-template

Returns complete, copy-paste-ready code examples.

**Templates:**
- `counter` - Simple counter with increment/decrement
- `api-call` - Fetch data with loading/error states
- `list` - Add/remove items with IdentifiedArray
- `timer` - Timer with start/stop controls

### lint-tca-code

Analyzes Swift code for TCA best practices.

**Checks:**
- ✓ State conforms to Equatable
- ✓ @Reducer annotation present
- ✓ All actions handled
- ✓ State structure best practices

### search-tca-docs

Searches documentation by keyword.

**Example:** Search for "navigation" → Returns stack and presentation patterns

### generate-reducer

Scaffolds a new TCA feature.

**Options:**
- `name` (required) - Feature name (e.g., "Counter", "User")
- `hasEffects` (optional) - Include dependency injection

## Testing the Server

```bash
# Start the server
npm start

# In another terminal, test with Node
node -e "import('./test-client.mjs').then(() => process.exit(0))"
```

## Architecture

The server communicates via **stdio** (standard input/output), which is the MCP standard for process-based communication.

- **Resources**: 6 TCA documentation topics
- **Tools**: 4 powerful tools for code generation, linting, and search
- **Transport**: stdio (Cursor native)

## Resources

- 📖 [Official TCA Documentation](https://pointfreeco.github.io/swift-composable-architecture/1.1.0/documentation/composablearchitecture/)
- 🔗 [Point-Free TCA](https://www.pointfree.co/episodes/ep86-the-composable-architecture-pt-1)
- 📝 [MCP Specification](https://modelcontextprotocol.io)

## Troubleshooting

**"Server not appearing in Cursor"**
- Verify the path is correct and absolute
- Check working directory matches server location
- Restart Cursor completely

**"Command not found"**
- Ensure Node.js is installed: `node --version`
- Check npm dependencies: `npm install`

**"Tool returns empty"**
- Ensure query matches documentation topic names
- Check tool parameters are correct

## Development

To add new tools or documentation:

1. Edit `server.js`
2. Add to `TCA_RESOURCES` for docs
3. Add to `CODE_TEMPLATES` for examples
4. Add handler in `CallToolRequestSchema`
5. Restart server

## License

MIT


