<script lang="ts" module>
  type ShaderLogs = {
    errors: GPUCompilationMessage[];
    warnings: GPUCompilationMessage[];
    info: GPUCompilationMessage[];
  };

  export type { ShaderLogs };
</script>

<script lang="ts">
  import shaderTemplate from "$lib/shaders/shaderTemplate.wgsl?raw";
  import pause from "$lib/icons/pause.svg";
  import play from "$lib/icons/play.svg";

  import { Loop } from "$lib/Loop";
  import { BufferWriter } from "$lib/BufferWriter";
  import { onDestroy, onMount } from "svelte";
  import { Texture } from "$lib/Texture";
  import { GPUTimer } from "$lib/GPUTimer";

  type Props = {
    width: number;
    height: number;
    logs: ShaderLogs | null;
  };

  let { width, height, logs = $bindable() }: Props = $props();

  const SETTINGS_BYTE_LENGTH: number = 6 * 4;
  const CANVAS_FORMAT: GPUTextureFormat = "rgba8unorm";

  const loop = new Loop({ wormholeThreshold: Infinity });

  let canvas: HTMLCanvasElement;
  let shaderSource: string;
  let gpu: GPUCanvasContext;
  let adapter: GPUAdapter;
  let device: GPUDevice;
  let bindGroupLayout0: GPUBindGroupLayout;
  let bindGroup0: GPUBindGroup;
  let bindGroupLayout1: GPUBindGroupLayout;
  let bindGroup1: GPUBindGroup;
  let sampler: GPUSampler;
  let renderPipelineLayout: GPUPipelineLayout;
  let renderPipeline: GPURenderPipeline | null = null;
  let gpuTimer: GPUTimer;
  let settingsBuffer: GPUBuffer;
  let channels: Texture[];

  let running = $state(false);
  let frameTime_ms = $state(0);
  let fps = $derived(frameTime_ms === 0 ? 0 : 1000 / frameTime_ms);

  let mostRecentCode = "";
  export async function recompile(code: string): Promise<void> {
    if (code === shaderSource) {
      mostRecentCode = code;
      return;
    }

    mostRecentCode = code;
    logs = null;

    if (adapter === undefined || device === undefined) {
      return;
    }

    const shader = device.createShaderModule({
      code: shaderTemplate + code,
    });

    shaderSource = code;

    const compilationInfo = await shader.getCompilationInfo();
    const errors = processCompilationMessages(
      compilationInfo.messages.filter((message) => message.type === "error")
    );
    const warnings = processCompilationMessages(
      compilationInfo.messages.filter((message) => message.type === "warning")
    );
    const info = processCompilationMessages(
      compilationInfo.messages.filter((message) => message.type === "info")
    );

    if (errors.length > 0 || warnings.length > 0 || info.length > 0) {
      stop();

      logs = {
        errors,
        warnings,
        info,
      };

      return;
    }

    renderPipeline = device.createRenderPipeline({
      layout: renderPipelineLayout,
      vertex: {
        module: shader,
        entryPoint: "_vertexMain",
      },
      fragment: {
        module: shader,
        targets: [
          {
            format: CANVAS_FORMAT,
          },
        ],
      },
    });

    gpuTimer.reset();

    if (running) {
      restart();
    }
  }

  export async function updateChannels(
    rawChannels: ArrayBuffer[]
  ): Promise<void> {
    channels?.forEach((channel) => channel.destroy());
    const promises = rawChannels.map((channel) =>
      channel.byteLength === 0
        ? Texture.colour(0, 0, 0)
        : Texture.fromArrayBuffer(channel)
    );

    channels = await Promise.all(promises);
    createBindGroup1();
  }

  function processCompilationMessages(
    messages: GPUCompilationMessage[]
  ): GPUCompilationMessage[] {
    return messages
      .sort((a, b) => a.offset - b.offset)
      .map(
        ({ length, lineNum, linePos, message, offset, type }) =>
          ({
            lineNum: lineNum - (shaderTemplate.match(/\n/g)?.length ?? 0),
            offset: offset - shaderTemplate.length,
            length,
            linePos,
            message,
            type,
          }) satisfies Omit<
            GPUCompilationMessage,
            "__brand"
          > as GPUCompilationMessage
      );
  }

  export function start(): void {
    loop.start();
    running = true;
  }

  export function stop(): void {
    loop.stop();
    running = false;
  }

  export function toggle(): void {
    loop.toggle();
    running = !running;
  }

  export function restart(): void {
    loop.restart();
    running = true;
  }

  export function save(): Promise<ArrayBuffer> {
    return new Promise<ArrayBuffer>((resolve, reject) => {
      canvas.toBlob((blob) => {
        if (blob === null) {
          reject();
          return;
        }

        blob.arrayBuffer().then(resolve);
      });
    });
  }

  function render(): void {
    if (
      adapter === undefined ||
      device === undefined ||
      renderPipeline === null
    ) {
      return;
    }

    const commandEncoder = device.createCommandEncoder();
    const renderPass = gpuTimer.beginRenderPass(commandEncoder, {
      colorAttachments: [
        {
          loadOp: "clear",
          storeOp: "store",
          view: gpu.getCurrentTexture().createView(),
        },
      ],
    });

    renderPass.setBindGroup(0, bindGroup0);
    renderPass.setBindGroup(1, bindGroup1);
    renderPass.setPipeline(renderPipeline);

    renderPass.draw(3);
    renderPass.end();

    device.queue.submit([commandEncoder.finish()]);
  }

  loop.addCallback((frameData) => {
    if (
      adapter === undefined ||
      device === undefined ||
      renderPipeline === null
    ) {
      return;
    }

    const bufferWriter = new BufferWriter(SETTINGS_BYTE_LENGTH);

    bufferWriter.writeUint32(width);
    bufferWriter.writeUint32(height);
    bufferWriter.writeFloat32(frameData.totalTime_ms / 1000);
    bufferWriter.writeFloat32(frameData.deltaTime_ms / 1000);
    bufferWriter.writeUint32(frameData.frame);
    bufferWriter.writeFloat32(1000 / frameData.deltaTime_ms);

    device.queue.writeBuffer(settingsBuffer, 0, bufferWriter.buffer);

    render();
  });

  onMount(async () => {
    if (!("gpu" in navigator)) {
      console.error("WebGPU not supported by your browser/device");
      return;
    }

    gpu = canvas.getContext("webgpu") as GPUCanvasContext;

    if (gpu === null) {
      console.error("Could not get WebGPU Canvas Rendering Context");
      return;
    }

    adapter = (await navigator.gpu.requestAdapter()) as GPUAdapter;

    if (adapter === null) {
      console.error(
        "Could not find valid GPU Adapter. Maybe WebGPU isn't supported by your browser/device?"
      );
      return;
    }

    device = await adapter.requestDevice({
      requiredFeatures: requestFeatures(adapter, "timestamp-query"),
    });

    gpu.configure({
      device,
      format: CANVAS_FORMAT,
    });

    gpuTimer = new GPUTimer(device, (time) => {
      const milliseconds = time / 1e6;
      frameTime_ms = milliseconds;
    });

    settingsBuffer = device.createBuffer({
      label: "Settings Buffer",
      size: SETTINGS_BYTE_LENGTH,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
    });

    bindGroupLayout0 = device.createBindGroupLayout({
      entries: [
        {
          binding: 0,
          buffer: { type: "uniform" },
          visibility: GPUShaderStage.FRAGMENT,
        },
        {
          binding: 1,
          sampler: {},
          visibility: GPUShaderStage.FRAGMENT,
        },
      ],
    });

    bindGroupLayout1 = device.createBindGroupLayout({
      entries: [
        {
          binding: 0,
          texture: {},
          visibility: GPUShaderStage.FRAGMENT,
        },
        {
          binding: 1,
          texture: {},
          visibility: GPUShaderStage.FRAGMENT,
        },
        {
          binding: 2,
          texture: {},
          visibility: GPUShaderStage.FRAGMENT,
        },
        {
          binding: 3,
          texture: {},
          visibility: GPUShaderStage.FRAGMENT,
        },
      ],
    });

    renderPipelineLayout = device.createPipelineLayout({
      bindGroupLayouts: [bindGroupLayout0, bindGroupLayout1],
    });

    // TODO: CUSTOM SAMPLERS
    sampler = device.createSampler({
      addressModeU: "repeat",
      addressModeV: "repeat",
    });

    if (channels === undefined) {
      await updateChannels([
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
      ]);
    }

    bindGroup0 = device.createBindGroup({
      layout: bindGroupLayout0,
      entries: [
        {
          binding: 0,
          resource: { buffer: settingsBuffer },
        },
        {
          binding: 1,
          resource: sampler,
        },
      ],
    });

    device.pushErrorScope("validation");

    if (mostRecentCode !== "") {
      await recompile(mostRecentCode);
    }

    if (mostRecentChannels.length > 0) {
      createBindGroup1();
    }
  });

  let mostRecentChannels: Texture[] = [];
  function createBindGroup1() {
    mostRecentChannels.forEach((channel) => channel.destroy());
    mostRecentChannels = channels;
    if (
      adapter === undefined ||
      device === undefined ||
      bindGroupLayout1 === undefined ||
      channels?.length !== 4
    ) {
      return;
    }

    channels.forEach((channel) => channel.initialise(device));

    bindGroup1 = device.createBindGroup({
      layout: bindGroupLayout1,
      entries: [
        {
          binding: 0,
          resource: channels[0].texture.createView(),
        },
        {
          binding: 1,
          resource: channels[1].texture.createView(),
        },
        {
          binding: 2,
          resource: channels[2].texture.createView(),
        },
        {
          binding: 3,
          resource: channels[3].texture.createView(),
        },
      ],
    });
  }

  function requestFeatures(
    adapter: GPUAdapter,
    ...features: GPUFeatureName[]
  ): GPUFeatureName[] {
    return features.filter((feature) => {
      const supported = adapter.features.has(feature);

      if (!supported) {
        console.warn(`GPU Feature ${feature} not supported`);
      }

      return supported;
    });
  }

  onDestroy(() => {
    stop();
    device?.destroy();
    settingsBuffer?.destroy();
    gpu?.unconfigure();
  });
</script>

<div class="container">
  <canvas bind:this={canvas} {width} {height}></canvas>
  <div class="controls">
    <input
      type="image"
      src={running ? pause : play}
      alt={running ? "Pause" : "Play"}
      onclick={toggle}
    />
    <span>{fps.toFixed(2)}fps</span>
    <span>{frameTime_ms.toFixed(2)}ms</span>
  </div>
</div>

<style lang="scss">
  .container,
  canvas {
    width: 100%;
    border-radius: 4px;
  }

  canvas {
    background-color: #000;
  }

  .controls {
    display: flex;
    align-items: center;
    gap: 1ch;

    height: 2em;
    border: 1px solid #000;
    border-radius: 4px;

    input[type="image"] {
      height: 2em;
    }
  }
</style>
