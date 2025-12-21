#!/usr/bin/env node

import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const DEFAULT_VERSION = "1.9.0";
const BASE_HOST = "https://pointfreeco.github.io/swift-composable-architecture";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const CACHE_DIR = path.join(__dirname, "cache");

function baseUrl(version) {
  return `${BASE_HOST}/${version}`;
}

async function ensureDir(dir) {
  await fs.mkdir(dir, { recursive: true });
}

async function readJsonFile(filePath) {
  const raw = await fs.readFile(filePath, "utf8");
  return JSON.parse(raw);
}

async function writeJsonFile(filePath, obj) {
  const raw = JSON.stringify(obj);
  await fs.writeFile(filePath, raw, "utf8");
}

async function fetchJson(url) {
  const response = await fetch(url, {
    headers: {
      "user-agent": "tca-docc-mcp/1.0",
      accept: "application/json",
    },
  });
  if (!response.ok) {
    const body = await response.text().catch(() => "");
    throw new Error(`Fetch failed (${response.status}) for ${url}${body ? `: ${body.slice(0, 200)}` : ""}`);
  }
  return response.json();
}

function normalizeDocPath(input) {
  const trimmed = (input ?? "").trim();
  if (!trimmed) throw new Error("path is required");

  const withLeadingSlash = trimmed.startsWith("/") ? trimmed : `/${trimmed}`;
  if (withLeadingSlash.startsWith("/documentation/")) return withLeadingSlash;

  if (withLeadingSlash.startsWith("/data/documentation/")) {
    // Allow callers to paste a data URL-like path; normalize back to documentation path.
    return withLeadingSlash.replace("/data/documentation/", "/documentation/").replace(/\\.json$/, "");
  }

  throw new Error('path must start with "/documentation/" (example: /documentation/composablearchitecture/gettingstarted)');
}

function docPathToDataUrl(version, docPath) {
  const normalized = normalizeDocPath(docPath);
  // DocC JSON is at: /data + docPath + .json
  // Example: /documentation/composablearchitecture/gettingstarted -> /data/documentation/composablearchitecture/gettingstarted.json
  const dataPath = `/data${normalized}.json`;
  // Ensure special characters are preserved correctly in the URL.
  const encoded = dataPath
    .split("/")
    .map((seg) => encodeURIComponent(seg))
    .join("/")
    .replace(/%2F/g, "/");
  return `${baseUrl(version)}${encoded}`;
}

async function loadIndex(version) {
  await ensureDir(CACHE_DIR);
  const cachePath = path.join(CACHE_DIR, `index-${version}.json`);

  try {
    return await readJsonFile(cachePath);
  } catch {
    // ignore
  }

  const url = `${baseUrl(version)}/index/index.json`;
  const indexJson = await fetchJson(url);
  await writeJsonFile(cachePath, indexJson);
  return indexJson;
}

function flattenIndex(indexJson) {
  const byPath = new Map();

  function walk(node) {
    if (Array.isArray(node)) {
      for (const item of node) walk(item);
      return;
    }
    if (!node || typeof node !== "object") return;

    if (typeof node.path === "string" && typeof node.title === "string") {
      if (!byPath.has(node.path)) {
        byPath.set(node.path, {
          path: node.path,
          title: node.title,
          type: node.type ?? null,
        });
      }
    }

    if (Array.isArray(node.children)) walk(node.children);
  }

  const swift = indexJson?.interfaceLanguages?.swift;
  walk(swift);
  return Array.from(byPath.values());
}

function clampString(str, maxChars) {
  if (str.length <= maxChars) return str;
  return `${str.slice(0, maxChars)}\n\n[Truncated at ${maxChars} characters]`;
}

function renderInline(inlineContent, references) {
  if (!Array.isArray(inlineContent)) return "";

  const out = [];
  for (const node of inlineContent) {
    if (!node || typeof node !== "object") continue;
    switch (node.type) {
      case "text":
        out.push(node.text ?? "");
        break;
      case "codeVoice":
        out.push("`" + (node.code ?? "") + "`");
        break;
      case "strong":
        out.push("**" + renderInline(node.inlineContent, references) + "**");
        break;
      case "emphasis":
        out.push("*" + renderInline(node.inlineContent, references) + "*");
        break;
      case "reference": {
        const ref = references?.[node.identifier];
        const title =
          ref?.title ??
          (Array.isArray(ref?.titleInlineContent) ? renderInline(ref.titleInlineContent, references) : null) ??
          node.identifier;
        const url = ref?.url ?? ref?.identifier ?? null;
        out.push(url ? `[${title}](${url})` : title);
        break;
      }
      default:
        // Fall back to any nested inlineContent
        if (Array.isArray(node.inlineContent)) out.push(renderInline(node.inlineContent, references));
        break;
    }
  }
  return out.join("");
}

function renderContentNodes(contentNodes, references) {
  if (!Array.isArray(contentNodes)) return "";
  const lines = [];

  for (const node of contentNodes) {
    if (!node || typeof node !== "object") continue;

    switch (node.type) {
      case "heading": {
        const level = Math.min(Math.max(Number(node.level ?? 2), 1), 6);
        lines.push(`${"#".repeat(level)} ${node.text ?? ""}`.trimEnd());
        lines.push("");
        break;
      }
      case "paragraph": {
        lines.push(renderInline(node.inlineContent, references).trim());
        lines.push("");
        break;
      }
      case "codeListing": {
        const lang = (node.syntax ?? "").toString().trim();
        const code =
          Array.isArray(node.code)
            ? node.code.join("\n")
            : (node.code ?? "").toString();
        lines.push("```" + lang);
        lines.push(code.trimEnd());
        lines.push("```");
        lines.push("");
        break;
      }
      case "aside": {
        const header = node.name ? `**${node.name}**` : null;
        const body = renderContentNodes(node.content, references).trim();
        const combined = [header, body].filter(Boolean).join("\n\n");
        lines.push(
          combined
            .split("\n")
            .map((l) => `> ${l}`)
            .join("\n")
        );
        lines.push("");
        break;
      }
      case "unorderedList": {
        for (const item of node.items ?? []) {
          const text = renderContentNodes(item?.content ?? [], references).trim().replace(/\n+/g, " ");
          lines.push(`- ${text}`);
        }
        lines.push("");
        break;
      }
      case "orderedList": {
        let i = 1;
        for (const item of node.items ?? []) {
          const text = renderContentNodes(item?.content ?? [], references).trim().replace(/\n+/g, " ");
          lines.push(`${i}. ${text}`);
          i += 1;
        }
        lines.push("");
        break;
      }
      default:
        // Some nodes embed content in different fields.
        if (Array.isArray(node.content)) {
          const rendered = renderContentNodes(node.content, references).trim();
          if (rendered) {
            lines.push(rendered);
            lines.push("");
          }
        }
        break;
    }
  }

  return lines.join("\n").trimEnd();
}

function renderDocToMarkdown(docJson, fallbackTitle) {
  const title = docJson?.metadata?.title ?? fallbackTitle ?? "TCA Documentation";
  const references = docJson?.references ?? {};

  const md = [];
  md.push(`# ${title}`);
  md.push("");

  if (Array.isArray(docJson?.abstract)) {
    const abstractText = docJson.abstract
      .map((a) => (a?.type === "text" ? a.text : ""))
      .join("")
      .trim();
    if (abstractText) {
      md.push(abstractText);
      md.push("");
    }
  }

  const primary = docJson?.primaryContentSections ?? [];
  for (const section of primary) {
    if (section?.kind === "content") {
      const rendered = renderContentNodes(section.content, references);
      if (rendered) {
        md.push(rendered);
        md.push("");
      }
    }
  }

  return md.join("\n").trimEnd();
}

// ----------------------------------------------------------------------------
// MCP server
// ----------------------------------------------------------------------------

const server = new Server(
  { name: "tca-docc-mcp", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "tca_docc_search",
        description:
          "Search the Point-Free TCA DocC index (v1.9.0 by default). Returns matching topic paths + titles.",
        inputSchema: {
          type: "object",
          properties: {
            query: { type: "string" },
            limit: { type: "number", default: 10 },
            version: { type: "string", default: DEFAULT_VERSION },
          },
          required: ["query"],
        },
      },
      {
        name: "tca_docc_get",
        description:
          'Fetch a TCA DocC topic by "/documentation/..." path and return rendered Markdown (or raw JSON).',
        inputSchema: {
          type: "object",
          properties: {
            path: { type: "string" },
            format: { type: "string", enum: ["markdown", "json"], default: "markdown" },
            version: { type: "string", default: DEFAULT_VERSION },
            maxChars: { type: "number", default: 16000 },
          },
          required: ["path"],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === "tca_docc_search") {
      const query = String(args?.query ?? "").trim();
      const version = String(args?.version ?? DEFAULT_VERSION).trim() || DEFAULT_VERSION;
      const limit = Math.max(1, Math.min(Number(args?.limit ?? 10), 50));

      const indexJson = await loadIndex(version);
      const entries = flattenIndex(indexJson);

      const q = query.toLowerCase();
      const results = entries
        .map((e) => {
          const title = (e.title ?? "").toLowerCase();
          const pathLower = (e.path ?? "").toLowerCase();
          const score =
            (title.includes(q) ? 3 : 0) +
            (pathLower.includes(q) ? 1 : 0) +
            (title.startsWith(q) ? 2 : 0);
          return { ...e, score };
        })
        .filter((r) => r.score > 0)
        .sort((a, b) => b.score - a.score)
        .slice(0, limit)
        .map(({ path, title, type }) => ({ path, title, type }));

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({ version, query, count: results.length, results }, null, 2),
          },
        ],
      };
    }

    if (name === "tca_docc_get") {
      const version = String(args?.version ?? DEFAULT_VERSION).trim() || DEFAULT_VERSION;
      const format = String(args?.format ?? "markdown");
      const maxChars = Math.max(2000, Math.min(Number(args?.maxChars ?? 16000), 100000));

      const docPath = normalizeDocPath(String(args?.path ?? ""));
      const dataUrl = docPathToDataUrl(version, docPath);

      const indexJson = await loadIndex(version);
      const entries = flattenIndex(indexJson);
      const fallbackTitle = entries.find((e) => e.path === docPath)?.title ?? null;

      const docJson = await fetchJson(dataUrl);
      const text =
        format === "json"
          ? JSON.stringify(docJson, null, 2)
          : renderDocToMarkdown(docJson, fallbackTitle);

      return {
        content: [
          {
            type: "text",
            text: clampString(text, maxChars),
          },
        ],
      };
    }

    throw new Error(`Unknown tool: ${name}`);
  } catch (error) {
    return {
      isError: true,
      content: [
        {
          type: "text",
          text: `Error: ${error?.message ?? String(error)}`,
        },
      ],
    };
  }
});

async function main() {
  await ensureDir(CACHE_DIR);
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((err) => {
  process.stderr.write(`${err?.stack ?? err}\n`);
  process.exit(1);
});
