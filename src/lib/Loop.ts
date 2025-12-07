type LoopSettings = {
  wormholeThreshold: number;
};

type FrameData = {
  deltaTime_ms: number;
  totalTime_ms: number;
  /** first frame is 1 */
  frame: number;
};

type LoopCallback = (frameData: FrameData) => unknown;

class Loop {
  private readonly callbacks: LoopCallback[] = [];

  public settings: LoopSettings;

  private frameID: number | null;
  private lastFrameTime: number;
  private totalTime: number;
  private frame: number;

  constructor(settings: Partial<LoopSettings> = {}) {
    this.frameID = null;
    this.lastFrameTime = 0;
    this.totalTime = 0;
    this.frame = 1;
    this.callbacks = [];

    this.settings = {
      wormholeThreshold: settings.wormholeThreshold ?? 500,
    };
  }

  public start(): void {
    if (this.running) {
      return;
    }

    this.frame = 1;
    this.totalTime = 0;
    this.lastFrameTime = -1;
    this.frameID = requestAnimationFrame(this.tick.bind(this));
  }

  public stop(): void {
    if (!this.running) {
      return;
    }

    cancelAnimationFrame(this.frameID as number);
    this.frameID = null;
  }

  public toggle(): void {
    if (this.running) {
      this.pause();
    } else {
      this.resume();
    }
  }

  public restart(): void {
    this.stop();
    this.start();
  }

  public pause(): void {
    this.stop();
  }

  public resume(): void {
    if (this.running) {
      return;
    }

    this.lastFrameTime = -1;
    this.frameID = requestAnimationFrame(this.tick.bind(this));
  }

  public addCallback(callback: LoopCallback): void {
    this.callbacks.push(callback);
  }

  private tick(tickTime: number): void {
    if (this.lastFrameTime < 0) {
      this.lastFrameTime = tickTime;
    }

    const deltaTimeMS = tickTime - this.lastFrameTime;
    const totalTimeMS = this.totalTime + deltaTimeMS;

    if (deltaTimeMS < this.settings.wormholeThreshold) {
      const frameData: FrameData = {
        deltaTime_ms: deltaTimeMS,
        totalTime_ms: totalTimeMS,
        frame: this.frame++,
      };

      for (const callback of this.callbacks) {
        callback(frameData);
      }

      this.totalTime = totalTimeMS;
    }

    this.lastFrameTime = tickTime;
    this.frameID = requestAnimationFrame(this.tick.bind(this));
  }

  public get running(): boolean {
    return this.frameID !== null;
  }
}

export { Loop };
export type { LoopSettings, FrameData, LoopCallback };
