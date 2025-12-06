<script lang="ts">
  import { onMount } from "svelte";
  import { liveQuery } from "dexie";
  import { database, type Project } from "$lib/Database";
  import "monaco-editor/min/vs/editor/editor.main.css";
  import ShaderPage from "../../lib/components/ShaderPage.svelte";
  import Shader404 from "$lib/components/Shader404.svelte";
  import ShaderList from "$lib/components/ShaderList.svelte";

  let hash = $state("");
  let id = $derived(parseInt(hash === "" ? "0" : hash.slice(1)));
  let project = $derived.by(() => {
    // noop just for reactivity
    // https://github.com/dexie/Dexie.js/issues/2075#issuecomment-2390570044
    id;

    return liveQuery(() => database.projects.get(id));
  });

  onMount(async () => {
    hash = location.hash;
  });
</script>

<svelte:window
  onhashchange={() => {
    hash = location.hash;
    id = parseInt(location.hash === "" ? "0" : location.hash.slice(1));
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
