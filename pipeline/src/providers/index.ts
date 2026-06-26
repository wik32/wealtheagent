import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import type { ExtractionProvider } from "./types.js";
import { MockProvider } from "./mock.js";
import { BedrockClaudeProvider } from "./bedrock-claude.js";
import { MistralProvider } from "./mistral.js";

export type ProviderName = "mock" | "claude" | "mistral";

const here = dirname(fileURLToPath(import.meta.url));
const DEFAULT_FIXTURE_DIR = join(here, "..", "..", "tests", "fixtures", "mock");

export function createProvider(
  name: ProviderName,
  options: { fixtureDir?: string } = {}
): ExtractionProvider {
  switch (name) {
    case "mock":
      return new MockProvider(options.fixtureDir ?? DEFAULT_FIXTURE_DIR);
    case "claude":
      return new BedrockClaudeProvider();
    case "mistral":
      return new MistralProvider();
  }
}

export * from "./types.js";
