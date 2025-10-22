# Quick Setup Guide

## Files Created

✅ `/Users/peter/Desktop/ScrollKitty/tca-mcp/server.js` - Main MCP server
✅ `/Users/peter/Desktop/ScrollKitty/tca-mcp/README.md` - Full documentation
✅ `/Users/peter/Desktop/ScrollKitty/tca-mcp/.gitignore` - Git ignore patterns

## Next Steps

### 1️⃣ Install Dependencies

Open Terminal and run:

```bash
cd /Users/peter/Desktop/ScrollKitty/tca-mcp
npm install
```

This will install `@modelcontextprotocol/sdk` which is required.

### 2️⃣ Add to Cursor

**Open Cursor:**
1. Go to **Settings** → **Features** → **MCP**
2. Click **"+ Add New MCP Server"**
3. Fill in:
   - **Name**: `tca-mcp`
   - **Transport**: `stdio`
   - **Command**: `node`
   - **Arguments**: `/Users/peter/Desktop/ScrollKitty/tca-mcp/server.js`
   - **Working Directory**: `/Users/peter/Desktop/ScrollKitty/tca-mcp`
4. Click **Add**
5. **Restart Cursor**

### 3️⃣ Test It Works

In Cursor's Chat/Composer, ask:

> "Generate a simple counter TCA feature"

Or:

> "Search TCA docs for effects"

The server should respond with code templates and documentation!

## What the Server Provides

### 📚 Documentation Topics
- Reducer Pattern
- Store Setup  
- Effects & Async
- Stack Navigation
- Presentation State
- Testing with TestStore

### 🔧 Tools
- `get-tca-template` - Ready-to-use code (counter, api-call, list, timer)
- `lint-tca-code` - Check Swift TCA code for issues
- `search-tca-docs` - Find documentation by topic
- `generate-reducer` - Scaffold new features

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "spawn /bin/zsh ENOENT" | This is a shell issue, not the server. Try: `npm install` directly in Terminal |
| Server not found in Cursor | Restart Cursor completely, verify paths are absolute |
| Dependencies not installing | Run `npm install` with full path: `/Users/peter/Desktop/ScrollKitty/tca-mcp` |

## File Structure

```
tca-mcp/
├── server.js          # Main MCP server (1000+ lines)
├── package.json       # Dependencies (create with: npm init -y)
├── README.md          # Full documentation
├── SETUP.md           # This file
└── node_modules/      # (created after npm install)
```

## Official References

- 📖 [TCA Docs v1.1.0](https://pointfreeco.github.io/swift-composable-architecture/1.1.0/documentation/composablearchitecture/)
- 🔗 [Point-Free](https://www.pointfree.co)
- 📝 [MCP Protocol](https://modelcontextprotocol.io)


