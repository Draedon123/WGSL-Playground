<script lang="ts">
  import { onMount } from "svelte";
  import shaderTemplate from "$lib/shaderTemplate.wgsl?raw";

  type Props = {
    width: number;
    height: number;
  };

  let { width, height }: Props = $props();

  const SETTINGS_BYTE_LENGTH: number = 4;
  const CANVAS_FORMAT: GPUTextureFormat = "rgba8unorm";

  let canvas: HTMLCanvasElement;
  let gpu: GPUCanvasContext;
  let adapter: GPUAdapter;
  let device: GPUDevice;
  let bindGroupLayout: GPUBindGroupLayout;
  let bindGroup: GPUBindGroup;
  let renderPipelineLayout: GPUPipelineLayout;
  let renderPipeline: GPURenderPipeline | null = null;
  let settingsBuffer: GPUBuffer;

  export async function recompile(code: string): Promise<Error | null> {
    if (adapter === undefined || device === undefined) {
      return null;
    }

    const shader = device.createShaderModule({
      code: shaderTemplate + code,
    });
    const compilationInfo = await shader.getCompilationInfo();

    if (compilationInfo.messages.length > 0) {
      return new Error("Invalid shader");
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

    render();

    return null;
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
  });
</script>

<canvas bind:this={canvas} {width} {height}></canvas>

<style lang="scss">
  canvas {
    background-color: #000;
    width: 100%;
  }
</style>
