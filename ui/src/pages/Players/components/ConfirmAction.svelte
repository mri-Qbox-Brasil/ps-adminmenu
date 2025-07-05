<script lang="ts">
  import Modal from '@components/Modal.svelte';

  export let confirmText: string;
  export let onConfirm: () => void;
  export let onCancel: () => void;
</script>

<Modal>
    <div class="flex justify-between items-center mb-[1vh] gap-[1vh]">
    <p class="font-medium text-[1.8vh] flex-1">{confirmText}</p>
    <button on:click={onCancel} class="hover:text-accent">
        <i class="fas fa-xmark"></i>
    </button>
    </div>

    <div class="flex justify-between gap-[1vh]">
        <button
        class="w-full bg-green-600 hover:bg-green-700 text-white px-[2vh] py-[1vh] rounded"
        on:click={onConfirm}
        >
        Confirmar
        </button>
        <button
        class="w-full bg-zinc-500 hover:bg-zinc-600 text-white px-[2vh] py-[1vh] rounded"
        on:click={onCancel}
        >
        Cancelar
        </button>
    </div>
</Modal>
