<script lang="ts">
  import ActionButton from './ActionButton.svelte';

  export let buttons = []; // Array de objetos com { icon, label, onClick }
</script>

<div class="w-full bg-tertiary flex rounded-[0.5vh]">
  {#each buttons as btn}
    <ActionButton {...btn} />
  {/each}
</div>
