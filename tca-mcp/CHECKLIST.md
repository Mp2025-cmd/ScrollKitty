# Setup Checklist

## Pre-Setup ✓

- [x] Server code created (`server.js`)
- [x] Package configuration created (`package.json`)
- [x] Documentation created (`README.md`, `SETUP.md`, `SUMMARY.md`)
- [x] Git ignore configured (`.gitignore`)

## Installation

- [ ] Terminal: `cd /Users/peter/Desktop/ScrollKitty/tca-mcp`
- [ ] Terminal: `npm install`
- [ ] Wait for installation to complete
- [ ] Verify: `ls node_modules/@modelcontextprotocol` should show `sdk`

## Cursor Configuration

- [ ] Open Cursor
- [ ] Go to **Settings**
- [ ] Click **Features**
- [ ] Click **MCP**
- [ ] Click **"+ Add New MCP Server"**

### Enter These Details:

- [ ] **Name:** `tca-mcp`
- [ ] **Transport:** `stdio`
- [ ] **Command:** `node`
- [ ] **Arguments:** `/Users/peter/Desktop/ScrollKitty/tca-mcp/server.js`
- [ ] **Working Directory:** `/Users/peter/Desktop/ScrollKitty/tca-mcp`

### Verify:

- [ ] Click **"Add"** button
- [ ] Server appears in MCP list
- [ ] Status shows "connected" or "active"

## Restart & Test

- [ ] Close Cursor completely (⌘Q)
- [ ] Wait 5 seconds
- [ ] Reopen Cursor
- [ ] Open Chat/Composer panel
- [ ] Try a test prompt:

**Test Prompt 1: Code Generation**
```
"Generate a simple counter feature in TCA"
```
- [ ] You receive complete Swift code
- [ ] Code includes @Reducer, State, Action, and View

**Test Prompt 2: Documentation**
```
"Search TCA docs for navigation"
```
- [ ] You get navigation documentation
- [ ] Results mention stack navigation and presentation

**Test Prompt 3: Linting**
```
"Check this for TCA issues: @Reducer struct Test { struct State {} enum Action {} }"
```
- [ ] Server finds missing Equatable conformance
- [ ] Reports it as an error

**Test Prompt 4: Scaffolding**
```
"Generate a User reducer with API effects"
```
- [ ] You get a reducer template
- [ ] Includes @Dependency annotation

## Success Indicators ✅

All these should be true:

- [ ] `npm install` completed without errors
- [ ] `node_modules/@modelcontextprotocol/sdk` exists
- [ ] Cursor shows MCP server in settings
- [ ] Chat responds to TCA-related queries
- [ ] Tools appear in tool list (hover over MCP server name)
- [ ] Code examples are complete and properly formatted
- [ ] Documentation searches return relevant results

## If Something Doesn't Work

### npm install fails
```bash
# Try with force flag
npm install --force

# Or clear cache and reinstall
npm cache clean --force
rm -rf node_modules
npm install
```

### Server not appearing in Cursor
1. Verify absolute paths (not relative)
2. Restart Cursor completely
3. Check working directory is correct
4. Try removing and re-adding the server

### Cursor says "Unknown tool"
1. Wait 30 seconds after adding
2. Fully close and reopen Cursor
3. Check that server shows as "connected"

### No response in chat
1. Look for error icon in MCP server row
2. Click to see error details
3. Check file paths are absolute and correct
4. Ensure `/tca-mcp` directory exists

## After Setup

Once verified, you can:

- [ ] Use `get-tca-template` for code examples
- [ ] Use `lint-tca-code` to check your code
- [ ] Use `search-tca-docs` for documentation
- [ ] Use `generate-reducer` to scaffold features
- [ ] Share the setup with teammates
- [ ] Add custom documentation/templates to `server.js`

## Customization (Optional)

To extend the server:

1. [ ] Edit `/Users/peter/Desktop/ScrollKitty/tca-mcp/server.js`
2. [ ] Add to `TCA_RESOURCES` for docs
3. [ ] Add to `CODE_TEMPLATES` for code examples
4. [ ] Restart server (Cursor will reconnect automatically)

## Support Files

Reference these if you need help:

- [ ] `README.md` - Full documentation
- [ ] `SETUP.md` - Detailed setup steps
- [ ] `SUMMARY.md` - Feature overview
- [ ] `server.js` - Source code (well-commented)

---

**Status:** Ready to install and configure! ✨


