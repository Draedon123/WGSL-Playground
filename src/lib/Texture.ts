import { fetchBlob } from "./fetch";

class Texture {
  public texture!: GPUTexture;

  private readonly source: GPUCopyExternalImageSource;
  private readonly width: number;
  private readonly height: number;
  private readonly label?: string;

  constructor(
    source: GPUCopyExternalImageSource,
    width: number,
    height: number,
    label?: string
  ) {
    this.source = source;
    this.width = width;
    this.height = height;
    this.label = label;
  }

  public get initialised(): boolean {
    return this.texture !== undefined;
  }

  public initialise(device: GPUDevice): this {
    this.texture = device.createTexture({
      label: this.label,
      size: [this.width, this.height],
      format: "rgba8unorm",
      usage:
        GPUTextureUsage.RENDER_ATTACHMENT |
        GPUTextureUsage.TEXTURE_BINDING |
        GPUTextureUsage.COPY_DST,
    });

    device.queue.copyExternalImageToTexture(
      {
        source: this.source,
        flipY: true,
      },
      {
        texture: this.texture,
        origin: [0, 0],
      },
      {
        width: this.width,
        height: this.height,
      }
    );

    return this;
  }

  public static async fetch(url: string, label?: string): Promise<Texture> {
    const bitmap = await Texture.toBitmap(url);

    return new Texture(bitmap, bitmap.width, bitmap.height, label);
  }

  public static async fromArrayBuffer(
    buffer: ArrayBuffer,
    label?: string
  ): Promise<Texture> {
    const bitmap = await createImageBitmap(new Blob([buffer]));

    return new Texture(bitmap, bitmap.width, bitmap.height, label);
  }

  /** 0-255 */
  public static colour(
    r: number,
    g: number,
    b: number,
    a: number = 255,
    label?: string
  ): Texture {
    const imageData = new ImageData(new Uint8ClampedArray([r, g, b, a]), 1, 1);

    return new Texture(imageData, 1, 1, label);
  }

  private static async toBitmap(url: string): Promise<ImageBitmap> {
    return await createImageBitmap(await fetchBlob(url));
  }

  public destroy(): void {
    this.texture?.destroy();
  }
}

export { Texture };
