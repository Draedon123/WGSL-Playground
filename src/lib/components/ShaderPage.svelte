<script lang="ts">
  import "monaco-editor/min/vs/editor/editor.main.css";

  import EditorWorker from "monaco-editor/esm/vs/editor/editor.worker?worker";
  import ShaderCanvas, {
    type ShaderLogs,
  } from "$lib/components/ShaderCanvas.svelte";

  import { onDestroy, onMount } from "svelte";
  import { database, type Project } from "$lib/Database";

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

  $effect(() => {
    // noop just for reactivity
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    logs;

    if (monaco === undefined || editor === undefined) {
      return;
    }

    updateMarkers();
  });

  function updateMarkers(): void {
    const model =
      editor.getModel() as import("monaco-editor").editor.ITextModel;

    if (logs === null) {
      monaco.editor.setModelMarkers(model, "validation", []);
      return;
    }

    monaco.editor.setModelMarkers(model, "validation", [
      ...logs.errors.map((error) =>
        createMarker(monaco.MarkerSeverity.Error, "Error", error)
      ),
      ...logs.warnings.map((warning) =>
        createMarker(monaco.MarkerSeverity.Warning, "Warning", warning)
      ),
    ]);
  }

  function createMarker(
    severity: import("monaco-editor").MarkerSeverity,
    type: string,
    message: GPUCompilationMessage
  ): import("monaco-editor").editor.IMarkerData {
    return {
      severity,
      startLineNumber: message.lineNum,
      startColumn: message.linePos,
      endLineNumber:
        message.lineNum +
        (project.code.slice(message.offset, message.length).match(/\n/g)
          ?.length ?? 0),
      endColumn:
        project.code.slice(message.offset, message.length).split("\n").at(-1)
          ?.length ?? message.linePos + message.offset,
      message: `${type}: ${message.message}`,
    };
  }

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

  async function nameOnChange(event: {
    currentTarget: HTMLInputElement;
  }): Promise<void> {
    const newName = event.currentTarget.value;

    project.name = newName;
    await database.projects.update(project, {
      name: newName,
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
      updateMarkers();
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

<div class="header">
  <input
    type="text"
    title="Click to rename!"
    name="project-name"
    onchange={nameOnChange}
    value={project.name}
  />
</div>

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
              <!-- eslint-disable-next-line svelte/require-each-key -->
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

<style lang="scss">
  $header-height: 2rem;
  .header {
    display: flex;
    justify-content: center;
    height: $header-height;
    padding: 8px 0;

    input {
      margin: 0;
      border: 2px solid transparent;
      padding: 5px 0;

      font-size: calc(0.8 * $header-height);
      width: max-content;

      text-align: center;
      font-weight: 600;

      transition: border-color 0.3s;
      &:hover {
        border-color: #000;
      }
    }
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

    .editor {
      height: 50vh;
    }
  }

  .centre {
    display: flex;
    width: 100%;

    justify-content: center;
  }
</style>
