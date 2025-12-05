<script lang="ts">
  import { resolve } from "$app/paths";
  import { onMount } from "svelte";

  let shader = $state("");
  onMount(() => {
    shader = location.hash.slice(1);
  });
</script>

<main>
  <h1>{shader}</h1>

  <a href={resolve("/")}>Home</a>
</main>

<style lang="scss">
  h1 {
    text-align: center;
  }
</style>
