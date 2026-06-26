import { mkdir, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { PDFDocument, StandardFonts, rgb } from "pdf-lib";
import sharp from "sharp";
import { SAMPLE_SPECS, type SampleSpec } from "./specs.js";

const here = dirname(fileURLToPath(import.meta.url));
const samplesDir = join(here, "samples");
const expectedDir = join(here, "expected");

async function makePdf(spec: SampleSpec): Promise<Uint8Array> {
  const pdf = await PDFDocument.create();
  const page = pdf.addPage([595, 842]);
  const font = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  let y = 790;
  spec.lines.forEach((line, i) => {
    page.drawText(line, {
      x: 60,
      y,
      size: i < 2 ? 13 : 11,
      font: i < 2 ? bold : font,
      color: rgb(0.1, 0.1, 0.1),
    });
    y -= i < 2 ? 22 : 18;
  });
  return pdf.save();
}

async function makePhoto(spec: SampleSpec): Promise<Buffer> {
  const lineSvgs = spec.lines
    .map((line, i) => {
      const y = 90 + spec.lines.slice(0, i).reduce((acc, _, j) => acc + (j < 2 ? 34 : 28), 0);
      const size = i < 2 ? 20 : 17;
      const weight = i < 2 ? "bold" : "normal";
      return `<text x="80" y="${y}" font-family="Helvetica, Arial" font-size="${size}" font-weight="${weight}" fill="#1c1c1c">${escapeXml(line)}</text>`;
    })
    .join("\n");
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="900" height="1273">
<rect width="900" height="1273" fill="#f4f1e8"/>
<rect x="30" y="30" width="840" height="1213" fill="#fdfcf7"/>
${lineSvgs}
</svg>`;

  return sharp(Buffer.from(svg))
    .rotate(1.8, { background: "#b8b0a0" })
    .modulate({ brightness: 0.96 })
    .blur(0.4)
    .jpeg({ quality: 72 })
    .toBuffer();
}

const escapeXml = (s: string) =>
  s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

await mkdir(samplesDir, { recursive: true });
await mkdir(expectedDir, { recursive: true });

for (const spec of SAMPLE_SPECS) {
  await writeFile(join(samplesDir, `${spec.name}.pdf`), await makePdf(spec));
  await writeFile(join(samplesDir, `${spec.name}_foto.jpg`), await makePhoto(spec));
  await writeFile(
    join(expectedDir, `${spec.name}.json`),
    JSON.stringify({ contractType: spec.contractType, data: spec.data }, null, 2) + "\n"
  );
  console.log(`generated ${spec.name} (.pdf, _foto.jpg, expected)`);
}
console.log(`\n${SAMPLE_SPECS.length} samples in ${samplesDir}`);
