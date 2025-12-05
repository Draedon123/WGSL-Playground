<script lang="ts">
  import { resolve } from "$app/paths";
  import { onMount } from "svelte";
  import { liveQuery } from "dexie";
  import { database, type Project } from "$lib/Database";

  let id = $state(1);
  let _project = liveQuery(() => database.projects.where({ id }).toArray());
  let project = $derived(($_project?.[0] ?? null) as Project | null);

  onMount(() => {
    id = parseInt(location.hash.slice(1));
  });
</script>

<svelte:head>
  <title>WGSL Playground - {project?.name ?? "Loading..."}</title>
</svelte:head>

<main>
  <h1>{project?.name ?? "Loading..."}</h1>

  <a href={resolve("/")}>Home</a>
</main>

<style lang="scss">
  h1 {
    text-align: center;
  }
</style>
