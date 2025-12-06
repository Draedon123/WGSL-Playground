<script lang="ts">
  import { onMount } from "svelte";
  import { liveQuery } from "dexie";
  import { database, type Project } from "$lib/Database";
  import "monaco-editor/min/vs/editor/editor.main.css";
  import ShaderPage from "../../lib/components/ShaderPage.svelte";

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

{#if $project === undefined && hash === ""}
  <main>
    <h1>Project Showcase</h1>
  </main>
{:else if $project === undefined && hash !== ""}
  <main>
    <h1>Project not found!</h1>
  </main>
{:else}
  <ShaderPage project={$project as Project} />
{/if}

<style lang="scss">
  h1 {
    text-align: center;
  }
</style>
