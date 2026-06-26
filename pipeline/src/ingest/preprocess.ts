import sharp from "sharp";

const MAX_DIMENSION = 1568;
const JPEG_QUALITY = 85;

export async function preprocessImage(bytes: Uint8Array): Promise<Uint8Array> {
  const out = await sharp(bytes)
    .rotate()
    .resize({
      width: MAX_DIMENSION,
      height: MAX_DIMENSION,
      fit: "inside",
      withoutEnlargement: true,
    })
    .normalize()
    .jpeg({ quality: JPEG_QUALITY })
    .toBuffer();
  return new Uint8Array(out);
}
