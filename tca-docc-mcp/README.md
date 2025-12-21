# TCA DocC MCP Server (v1.9.0)

An MCP server that connects directly to the official Point-Free TCA DocC site and exposes:

- Search across the DocC index
- Fetch any topic as Markdown (rendered from DocC JSON)

Docs source:
`https://pointfreeco.github.io/swift-composable-architecture/1.9.0/documentation/composablearchitecture/`

## Setup (Cursor)

1. Install dependencies:

```bash
cd /Users/peter/Desktop/ScrollKitty/tca-docc-mcp
npm install
```

2. Cursor → Settings → Features → MCP → “Add New MCP Server”

- Name: `tca-docc-mcp`
- Transport: `stdio`
- Command: `node`
- Arguments: `/Users/peter/Desktop/ScrollKitty/tca-docc-mcp/server.js`
- Working Directory: `/Users/peter/Desktop/ScrollKitty/tca-docc-mcp`

3. Restart Cursor.

## Tools

- `tca_docc_search`
  - Params: `query` (string), `limit` (number, optional), `version` (string, optional)
- `tca_docc_get`
  - Params: `path` (string), `format` (`markdown`|`json`, optional), `version` (string, optional)

Examples to ask in chat:

- “Search TCA docs for presentation state”
- “Open TCA docs for `/documentation/composablearchitecture/presentationstate`”

