<script lang="ts">
  import "monaco-editor/min/vs/editor/editor.main.css";

  import ShaderPage from "$lib/components/ShaderPage.svelte";
  import Shader404 from "$lib/components/Shader404.svelte";
  import ShaderList from "$lib/components/ShaderList.svelte";

  import { onMount } from "svelte";
  import { liveQuery } from "dexie";
  import { database, type Project } from "$lib/Database";
  import { writable } from "svelte/store";

  let hash = $state("");
  let id = $derived(parseInt(hash.startsWith("#id=") ? hash.slice(4) : "-1"));
  let source = $derived(
    hash.startsWith("#raw=") ? decodeURIComponent(hash.slice(5)) : ""
  );
  let project = $derived(
    id !== -1
      ? liveQuery(() => database.projects.get(id))
      : source !== ""
        ? writable<Project>({
            code: source,
            name: "Untitled",
            thumbnail: new ArrayBuffer(),
          })
        : undefined
  );

  onMount(() => {
    hash = location.hash;
  });
</script>

<svelte:window
  onhashchange={() => {
    hash = location.hash;
  }}
/>

<main>
  {#if $project === undefined && hash === ""}
    <ShaderList />
  {:else if $project === undefined && hash !== ""}
    <Shader404 />
  {:else}
    <ShaderPage project={$project as Project} />
  {/if}
</main>
