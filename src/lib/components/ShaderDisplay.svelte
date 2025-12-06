<script lang="ts" module>
  type ShaderLogs = {
    errors: GPUCompilationMessage[];
    warnings: GPUCompilationMessage[];
    info: GPUCompilationMessage[];
  };

  export type { ShaderLogs };
</script>

<script lang="ts">
  import { onDestroy, onMount } from "svelte";
  import shaderTemplate from "$lib/shaderTemplate.wgsl?raw";
  import { Loop } from "$lib/Loop";
  import { BufferWriter } from "$lib/BufferWriter";

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
  let gpu: GPUCanvasContext;
  let adapter: GPUAdapter;
  let device: GPUDevice;
  let bindGroupLayout: GPUBindGroupLayout;
  let bindGroup: GPUBindGroup;
  let renderPipelineLayout: GPUPipelineLayout;
  let renderPipeline: GPURenderPipeline | null = null;
  let settingsBuffer: GPUBuffer;

  let mostRecentCode = "";
  export async function recompile(code: string): Promise<void> {
    mostRecentCode = code;
    logs = null;

    if (adapter === undefined || device === undefined) {
      return;
    }

    const shader = device.createShaderModule({
      code: shaderTemplate + code,
    });

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

    restart();
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
  }

  export function stop(): void {
    loop.stop();
  }

  export function toggle(): void {
    loop.toggle();
  }

  export function restart(): void {
    loop.restart();
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
    const renderPass = commandEncoder.beginRenderPass({
      colorAttachments: [
        {
          loadOp: "clear",
          storeOp: "store",
          view: gpu.getCurrentTexture().createView(),
        },
      ],
    });

    renderPass.setBindGroup(0, bindGroup);
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
    bufferWriter.writeFloat32(frameData.frame);
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

    device = await adapter.requestDevice();

    gpu.configure({
      device,
      format: CANVAS_FORMAT,
    });

    settingsBuffer = device.createBuffer({
      label: "Settings Buffer",
      size: SETTINGS_BYTE_LENGTH,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
    });

    bindGroupLayout = device.createBindGroupLayout({
      entries: [
        {
          binding: 0,
          buffer: { type: "uniform" },
          visibility: GPUShaderStage.FRAGMENT,
        },
      ],
    });

    renderPipelineLayout = device.createPipelineLayout({
      bindGroupLayouts: [bindGroupLayout],
    });

    bindGroup = device.createBindGroup({
      layout: bindGroupLayout,
      entries: [
        {
          binding: 0,
          resource: { buffer: settingsBuffer },
        },
      ],
    });

    device.pushErrorScope("validation");

    if (mostRecentCode !== "") {
      await recompile(mostRecentCode);
    }
  });

  onDestroy(() => {
    stop();
    device?.destroy();
    settingsBuffer?.destroy();
    gpu?.unconfigure();
  });
</script>

<canvas bind:this={canvas} {width} {height}></canvas>

<style lang="scss">
  canvas {
    background-color: #000;
    width: 100%;
  }
</style>
