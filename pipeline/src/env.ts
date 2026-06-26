import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

export function loadEnv(): void {
  const envPath = join(dirname(fileURLToPath(import.meta.url)), "..", ".env");
  try {
    process.loadEnvFile(envPath);
  } catch {
    return;
  }
}
