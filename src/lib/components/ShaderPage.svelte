<script lang="ts">
  import { onDestroy, onMount } from "svelte";
  import { database, type Project } from "$lib/Database";
  import "monaco-editor/min/vs/editor/editor.main.css";
  import EditorWorker from "monaco-editor/esm/vs/editor/editor.worker?worker";
  import ShaderCanvas, {
    type ShaderLogs,
  } from "$lib/components/ShaderCanvas.svelte";

  type Props = {
    project: Project;
  };

  let { project }: Props = $props();

  let monaco: typeof import("monaco-editor");
  let id = $state(1);
  let shaderCanvas: ShaderCanvas;
  let editorElement: HTMLDivElement;
  let editor: import("monaco-editor").editor.IStandaloneCodeEditor;
  let logs: ShaderLogs | null = $state(null);

  $effect(() => {
    shaderCanvas.recompile(project.code);
  });

  async function editorOnKeyDown(event: KeyboardEvent): Promise<void> {
    if (event.code !== "KeyS" || !event.ctrlKey) {
      return;
    }

    event.preventDefault();
    updateCode();
  }

  async function updateCode(newCode = editor?.getValue() ?? ""): Promise<void> {
    project.code = newCode;

    await shaderCanvas.recompile(project.code);
    await database.projects.update(id, {
      code: project.code,
    });
  }

  onMount(async () => {
    id = parseInt(location.hash === "" ? "0" : location.hash.slice(1));

    // avoid reference to `window` during ssr
    monaco = await import("monaco-editor");

    self.MonacoEnvironment = {
      getWorker: () => new EditorWorker(),
    };

    editor = monaco.editor.create(editorElement, {
      automaticLayout: true,
      theme: "vs-dark",
    });

    if (project.code) {
      editor.setModel(monaco.editor.createModel(project.code, "wgsl"));
    }

    shaderCanvas.start();
  });

  onDestroy(() => {
    monaco?.editor.getModels().forEach((model) => model.dispose());
    editor?.dispose();
  });
</script>

<svelte:head>
  <title>WGSL Playground - {project.name}</title>
</svelte:head>

<svelte:window
  onhashchange={() => {
    id = parseInt(location.hash === "" ? "0" : location.hash.slice(1));
  }}
/>

<main>
  <h1>{project.name}</h1>

  <div class="centre">
    <div class="main">
      <div class="canvas">
        <ShaderCanvas
          bind:this={shaderCanvas}
          bind:logs
          width={800}
          height={450}
        />
      </div>
      <!-- svelte-ignore a11y_no_static_element_interactions -->
      <div
        class="editor"
        bind:this={editorElement}
        onkeydown={editorOnKeyDown}
      ></div>
      <div class="logs">
        {#if logs !== null}
          {#snippet Log(
            messages: GPUCompilationMessage[],
            type: string,
            header: string
          )}
            {#if messages.length > 0}
              <h1>{header}</h1>

              <ul>
                {#each messages as message}
                  <li>
                    {type} at {message.lineNum}:{message.linePos}. {message.message}.
                    Source: {project.code.slice(
                      message.offset,
                      message.offset + message.length
                    )}
                  </li>
                {/each}
              </ul>
            {/if}
          {/snippet}

          {@render Log(logs.errors, "Error", "Errors")}
          {@render Log(logs.warnings, "Warning", "Warnings")}
          {@render Log(logs.info, "Info", "Info")}
        {/if}
      </div>
    </div>
  </div>
</main>

<style lang="scss">
  h1 {
    text-align: center;
  }

  .main {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;

    width: 80%;
    min-height: 50vh;
  }

  $margin: 1%;

  .canvas,
  .editor {
    width: calc(50% - 0.5 * $margin);
  }

  .canvas {
    margin-right: calc(0.5 * $margin);
  }

  .editor {
    margin-left: calc(0.5 * $margin);
  }

  @media screen and (max-width: 1000px) {
    .main {
      flex-direction: column;
    }

    .canvas,
    .editor {
      width: 100%;
      margin: 0;
    }
  }

  .centre {
    display: flex;
    width: 100%;

    justify-content: center;
  }
</style>
