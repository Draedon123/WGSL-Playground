<script lang="ts">
  import "monaco-editor/min/vs/editor/editor.main.css";

  import ShaderPage from "$lib/components/ShaderPage.svelte";
  import Shader404 from "$lib/components/Shader404.svelte";
  import ShaderList from "$lib/components/ShaderList.svelte";

  import { onMount } from "svelte";
  import { liveQuery } from "dexie";
  import { database, type Project } from "$lib/Database";
  import { getHash } from "$lib/hash";

  let hash = $state("");
  let id = $derived(parseInt(getHash("id", hash) ?? "0"));
  let showcase = $derived(getHash("showcase", hash) === "1");
  let project = $derived.by(() => {
    // noop just for reactivity
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    id;

    const table = showcase ? database.showcase : database.projects;
    return liveQuery(() => table.get(id));
  });

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
