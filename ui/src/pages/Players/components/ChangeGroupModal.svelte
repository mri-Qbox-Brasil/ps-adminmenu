<script lang="ts">
  import Modal from '@components/Modal.svelte';
  import Autofill from '@components/Autofill.svelte';
  import { SELECTED_PLAYER } from '@store/players';
  import { SendNUI } from '@utils/SendNUI';

  export let type: 'job' | 'gang'; // Define se é emprego ou gangue
  export let onClose: () => void;

  let selectedData = {};

  function selectData(obj) {
    selectedData[obj.id] = obj;
  }

  function confirm() {
    const dataKey = type === 'job' ? 'Job' : 'Gang';
    SendNUI('clickButton', {
      data: type === 'job' ? 'set_job' : 'set_gang',
      selectedData: {
        Player: { value: $SELECTED_PLAYER.id },
        [dataKey]: { value: selectedData[dataKey]?.value },
      },
    });
    onClose();
  }
</script>

<Modal>
  <div class="flex justify-between items-center mb-[1vh]">
    <p class="font-medium text-[1.8vh]">Definir {type === 'job' ? 'Emprego' : 'Gangue'}</p>
    <button on:click={onClose} class="hover:text-accent">
      <i class="fas fa-xmark"></i>
    </button>
  </div>

  <Autofill
    label_title={type === 'job' ? 'Job' : 'Gang'}
    data={type === 'job' ? 'jobs' : 'gangs'}
    action={null}
    {selectData}
    selectedData={selectData}
  />

  <button
    class="h-[3.8vh] px-[1.5vh] mt-[2vh] rounded-[0.5vh] bg-secondary hover:bg-opacity-90 border border-primary w-full"
    on:click={confirm}
  >
    <p>Confirmar</p>
  </button>
</Modal>
