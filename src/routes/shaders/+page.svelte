<script lang="ts">
  import { resolve } from "$app/paths";
  import { onDestroy, onMount } from "svelte";
  import { liveQuery } from "dexie";
  import { database, type Project } from "$lib/Database";
  import "monaco-editor/min/vs/editor/editor.main.css";
  import EditorWorker from "monaco-editor/esm/vs/editor/editor.worker?worker";
  import ShaderDisplay from "$lib/components/ShaderDisplay.svelte";

  let monaco: typeof import("monaco-editor");
  let id = $state(1);
  let _project = liveQuery(() => database.projects.where({ id }).toArray());
  let project = $derived(($_project?.[0] ?? null) as Project | null);
  let code = $derived(project?.code ?? "");
  let shaderDisplay: ShaderDisplay;
  let editorElement: HTMLDivElement;
  let editor: import("monaco-editor").editor.IStandaloneCodeEditor;

  async function updateCode(event: KeyboardEvent): Promise<void> {
    if (editor === undefined) {
      return;
    }

    if (event.code !== "KeyS" || !event.ctrlKey) {
      return;
    }

    event.preventDefault();

    code = editor.getValue();
    await shaderDisplay.recompile(code);
  }

  onMount(async () => {
    id = parseInt(location.hash.slice(1));

    // avoid reference to `window` during ssr
    monaco = await import("monaco-editor");

    self.MonacoEnvironment = {
      getWorker: () => new EditorWorker(),
    };

    editor = monaco.editor.create(editorElement, {
      automaticLayout: true,
      theme: "vs-dark",
    });

    editor.setModel(monaco.editor.createModel(code ?? "", "wgsl"));
  });

  onDestroy(() => {
    monaco?.editor.getModels().forEach((model) => model.dispose());
    editor?.dispose();
  });
</script>

<svelte:head>
  <title>WGSL Playground - {project?.name ?? "Loading..."}</title>
</svelte:head>

<main>
  <h1>{project?.name ?? "Loading..."}</h1>

  <a href={resolve("/")}>Home</a>

  <div class="centre">
    <div class="main">
      <div class="canvas">
        <ShaderDisplay bind:this={shaderDisplay} />
      </div>
      <!-- svelte-ignore a11y_no_static_element_interactions -->
      <div
        class="editor"
        bind:this={editorElement}
        onkeydown={updateCode}
      ></div>
    </div>
  </div>
</main>

<style lang="scss">
  h1 {
    text-align: center;
  }

  .main {
    display: flex;

    width: 80%;
    min-height: 50vh;
  }

  .canvas {
    background-color: #000;
    width: 50%;
  }

  .editor {
    width: 50%;
  }

  @media screen and (max-width: 1000px) {
    .main {
      flex-direction: column;
    }

    .canvas,
    .editor {
      width: 100%;
    }
  }

  .centre {
    display: flex;
    width: 100%;

    justify-content: center;
  }
</style>
