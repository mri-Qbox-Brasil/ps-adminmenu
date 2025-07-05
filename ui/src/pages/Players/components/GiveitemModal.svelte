<script lang="ts">
  import Modal from '@components/Modal.svelte';
  import Autofill from '@components/Autofill.svelte';
  import { SendNUI } from '@utils/SendNUI';

  export let player = null;
  export let onClose: () => void;

  let selectedItem = null;
  let quantity = 1;

  function confirmGive() {
    if (!selectedItem || quantity <= 0 || !player) return;

    SendNUI('clickButton', {
      type: 'server',
      data: 'give_item',
      selectedData: {
        Player: { value: player.id },
        Item: { value: selectedItem.value },
        Amount: { value: quantity }
      }
    });

    onClose();
  }
</script>

<Modal>
  <div class="flex justify-between items-center mb-[1vh]">
    <p class="font-medium text-[1.8vh]">Dar item para {player?.name}</p>
    <button on:click={onClose} class="hover:text-accent">
      <i class="fas fa-xmark"></i>
    </button>
  </div>

  <Autofill
    label_title="Selecionar Item"
    data="items"
    selectedData={(data) => (selectedItem = data)}
  />

  <div class="mt-4">
    <label class="block text-sm font-medium text-gray-300">Quantidade</label>
    <input
      type="number"
      min="1"
      bind:value={quantity}
      class="w-full px-3 py-2 border border-gray-600 rounded bg-tertiary text-white"
    />
  </div>

  <button
    class="mt-4 h-[3.8vh] px-[1.5vh] rounded-[0.5vh] bg-secondary hover:bg-opacity-90 border border-primary w-full"
    on:click={confirmGive}
  >
    Confirmar
  </button>
</Modal>
