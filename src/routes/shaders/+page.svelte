<script lang="ts">
  import { resolve } from "$app/paths";
  import { onMount } from "svelte";
  import { liveQuery } from "dexie";
  import { database } from "$lib/Database";

  let id = $state(1);
  let project = liveQuery(() => database.projects.where({ id }).toArray());

  onMount(() => {
    id = parseInt(location.hash.slice(1));
  });
</script>

<main>
  <h1>{$project?.[0].name ?? "Loading..."}</h1>

  <a href={resolve("/")}>Home</a>
</main>

<style lang="scss">
  h1 {
    text-align: center;
  }
</style>
