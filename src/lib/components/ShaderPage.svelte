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
    showcase: boolean;
  };

  let { project, showcase }: Props = $props();

  let monaco: typeof import("monaco-editor");
  let shaderCanvas: ShaderCanvas;
  let editorElement: HTMLDivElement;
  let editor: import("monaco-editor").editor.IStandaloneCodeEditor;
  let logs: ShaderLogs | null = $state(null);

  $effect(() => {
    if (editor?.getValue() !== project.code) {
      editor?.setValue(project.code);
    }

    shaderCanvas.recompile(project.code);
    shaderCanvas.updateChannels(project.channels);
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
    const messageSection = project.code.slice(message.offset, message.length);
    const lines = messageSection.split("\n");

    return {
      severity,
      startLineNumber: message.lineNum,
      startColumn: message.linePos,
      endLineNumber:
        message.lineNum + (messageSection.match(/\n/g)?.length ?? 0),
      endColumn:
        lines.length > 1
          ? // lines.at(-1) is defined since the length of the array is > 1
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            lines.at(-1)!.length
          : message.linePos + message.length,
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
    const compiled = await shaderCanvas.recompile(newCode);

    if (!showcase) {
      project.code = newCode;

      setTimeout(async () => {
        const thumbnail = compiled
          ? await shaderCanvas.save()
          : project.thumbnail;

        await database.projects.update(project, {
          code: project.code,
          thumbnail,
        });
      }, 10);
    }
  }

  async function nameOnChange(event: {
    currentTarget: HTMLInputElement;
  }): Promise<void> {
    if (showcase) {
      return;
    }

    const newName = event.currentTarget.value;

    project.name = newName;
    await database.projects.update(project, {
      name: newName,
    });
  }

  onMount(async () => {
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

<div class="header">
  <input
    type="text"
    title={showcase ? "Readonly!" : "Click to rename!"}
    name="project-name"
    onchange={nameOnChange}
    disabled={showcase}
    value={project.name}
    autocomplete="off"
  />
</div>

<div class="centre">
  <div class="main">
    <div class="canvas">
      <ShaderCanvas bind:this={shaderCanvas} bind:logs />
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

    <div class="options"></div>
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
      padding: 5px 0;
      border: none;

      font-size: calc(0.8 * $header-height);
      width: 100%;

      text-align: center;
      font-weight: 600;

      color: #fff;
      background-color: transparent;

      &:focus {
        outline: none;
      }
    }
  }

  .main {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;

    width: 80%;
    min-height: 50vh;

    row-gap: 10px;
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
    max-height: 50vh;
  }

  @media screen and (max-width: 1000px) {
    .main {
      flex-direction: column;

      row-gap: 0px;
    }

    .canvas,
    .editor {
      width: 100%;
      margin: 0;
    }

    .editor {
      height: 40vh;
    }
  }

  .centre {
    display: flex;
    width: 100%;

    justify-content: center;
  }
</style>
