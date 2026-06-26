import { readFile } from "node:fs/promises";
import { extname, basename } from "node:path";
import { preprocessImage } from "./preprocess.js";

export type DocumentInput =
  | { kind: "pdf"; name: string; bytes: Uint8Array }
  | { kind: "images"; name: string; pages: Uint8Array[] };

const MAX_PDF_BYTES = 4 * 1024 * 1024;
const IMAGE_EXTENSIONS = new Set([".png", ".jpg", ".jpeg", ".webp", ".heic"]);

export class UnsupportedDocumentError extends Error {}

export async function loadDocument(filePath: string): Promise<DocumentInput> {
  const ext = extname(filePath).toLowerCase();
  const name = basename(filePath, extname(filePath));
  const bytes = await readFile(filePath);

  if (ext === ".pdf") {
    if (bytes.byteLength > MAX_PDF_BYTES) {
      throw new UnsupportedDocumentError(
        `PDF exceeds ${MAX_PDF_BYTES / 1024 / 1024} MB provider limit: ${filePath}. ` +
          `Split it or photograph the relevant pages.`
      );
    }
    return { kind: "pdf", name, bytes };
  }

  if (IMAGE_EXTENSIONS.has(ext)) {
    const processed = await preprocessImage(bytes);
    return { kind: "images", name, pages: [processed] };
  }

  throw new UnsupportedDocumentError(
    `Unsupported file type "${ext}". Supported: .pdf, ${[...IMAGE_EXTENSIONS].join(", ")}`
  );
}

export async function loadImagePages(filePaths: string[]): Promise<DocumentInput> {
  const pages: Uint8Array[] = [];
  for (const p of filePaths) {
    const ext = extname(p).toLowerCase();
    if (!IMAGE_EXTENSIONS.has(ext)) {
      throw new UnsupportedDocumentError(`Multi-page input must be images, got "${ext}"`);
    }
    pages.push(await preprocessImage(await readFile(p)));
  }
  const first = filePaths[0];
  return { kind: "images", name: first ? basename(first, extname(first)) : "document", pages };
}
